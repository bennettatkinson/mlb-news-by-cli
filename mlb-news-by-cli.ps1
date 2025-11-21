#!/usr/bin/env pwsh
<#
.SYNOPSIS
    MLB News By CLI - Displays MLB trade news, player news, and transactions with flexible filtering
.DESCRIPTION
    This script searches for and displays MLB news using web searches.
    Search by team, specific players, or combinations of both.
    Supports multiple date range options: hours back, specific date, or custom date range.
    You can also filter by specific news types (trades, roster moves, signings, etc.).
.PARAMETER Team
    MLB team to search for. Leave blank for all teams.
    Examples: Yankees, Dodgers, Red Sox, Braves, etc. (any of the 30 MLB teams)
.PARAMETER Player
    Specific player(s) to search for. Can specify multiple players.
    Examples: -Player "Juan Soto" or -Player "Juan Soto","Aaron Judge"
.PARAMETER Hours
    Number of hours to look back for news (default: 24). Max: 8760 (1 year)
.PARAMETER Date
    Search for news on a specific date (e.g., "2025-11-15" or "November 15, 2025")
.PARAMETER StartDate
    Start date for custom date range (e.g., "2025-11-01")
.PARAMETER EndDate
    End date for custom date range (e.g., "2025-11-20"). Defaults to today if not specified.
.PARAMETER VerboseOutput
    Enable verbose output to see detailed search information
.PARAMETER Sources
    Select which news sources to query. Options: Trade, Roster, Transaction, Signing, Acquisition, General, All
    Default: All
    You can specify multiple sources: -Sources Trade,Signing
.EXAMPLE
    ./mlb-news-by-cli.ps1
    Default: Search all teams, all sources, last 24 hours
.EXAMPLE
    ./mlb-news-by-cli.ps1 -Team Yankees
    Search Yankees news from last 24 hours
.EXAMPLE
    ./mlb-news-by-cli.ps1 -Team Yankees -Sources Trade
    Search only Yankees trade news from last 24 hours
.EXAMPLE
    ./mlb-news-by-cli.ps1 -Player "Juan Soto"
    Search Juan Soto news from last 24 hours
.EXAMPLE
    ./mlb-news-by-cli.ps1 -Player "Juan Soto","Aaron Judge"
    Search news about Juan Soto and Aaron Judge from last 24 hours
.EXAMPLE
    ./mlb-news-by-cli.ps1 -Team Yankees -Hours 168 -Sources Trade,Signing
    Search Yankees trade and signing news from last 7 days
.EXAMPLE
    ./mlb-news-by-cli.ps1 -Team Dodgers -StartDate "2025-11-01" -EndDate "2025-11-15" -Sources Signing
    Search Dodgers signing news between two dates
.EXAMPLE
    ./mlb-news-by-cli.ps1 -Player "Mike Trout" -VerboseOutput
    Search Mike Trout news with detailed debugging output
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('All', 'Diamondbacks', 'Braves', 'Orioles', 'Red Sox', 
                 'Cubs', 'White Sox', 'Reds', 'Guardians', 'Rockies',
                 'Tigers', 'Astros', 'Royals', 'Angels', 'Dodgers',
                 'Marlins', 'Brewers', 'Twins', 'Mets', 'Yankees',
                 'Athletics', 'Phillies', 'Pirates', 'Padres', 'Giants',
                 'Mariners', 'Cardinals', 'Rays', 'Rangers', 'Blue Jays',
                 'Nationals')]
    [string]$Team = 'All',
    
    [Parameter(Mandatory=$false)]
    [string[]]$Player,
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(1, 8760)]
    [int]$Hours,
    
    [Parameter(Mandatory=$false)]
    [DateTime]$Date,
    
    [Parameter(Mandatory=$false)]
    [DateTime]$StartDate,
    
    [Parameter(Mandatory=$false)]
    [DateTime]$EndDate,
    
    [Parameter(Mandatory=$false)]
    [switch]$VerboseOutput,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Trade', 'Roster', 'Transaction', 'Signing', 'Acquisition', 'General', 'All')]
    [string[]]$Sources = @('All')
)

# Color scheme for terminal output
$colors = @{
    Header = 'Cyan'
    Title = 'Green'
    Date = 'Yellow'
    Source = 'Magenta'
    Separator = 'DarkGray'
    Info = 'White'
    Error = 'Red'
    Success = 'Green'
}

function Write-ColorText {
    param(
        [string]$Text,
        [string]$Color = 'White',
        [switch]$NoNewline
    )
    if ($NoNewline) {
        Write-Host $Text -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

function Get-DateRange {
    <#
    .SYNOPSIS
    Determines the date range to search based on provided parameters
    #>
    param(
        [hashtable]$BoundParams
    )
    
    $now = Get-Date
    $start = $null
    $end = $now
    $description = ""
    
    # Determine which parameter set is being used
    if ($BoundParams.ContainsKey('Date')) {
        # Specific date - search entire day
        $dateValue = $BoundParams['Date']
        $start = $dateValue.Date
        $end = $dateValue.Date.AddDays(1).AddSeconds(-1)
        $description = "on $($dateValue.ToString('MMMM dd, yyyy'))"
    }
    elseif ($BoundParams.ContainsKey('StartDate') -or $BoundParams.ContainsKey('EndDate')) {
        # Date range
        if ($BoundParams.ContainsKey('StartDate')) {
            $startDateValue = $BoundParams['StartDate']
            $start = $startDateValue.Date
        } else {
            # Default to 30 days back if only EndDate provided
            $endDateValue = $BoundParams['EndDate']
            $start = $endDateValue.AddDays(-30).Date
        }
        
        if ($BoundParams.ContainsKey('EndDate')) {
            $endDateValue = $BoundParams['EndDate']
            $end = $endDateValue.Date.AddDays(1).AddSeconds(-1)
        }
        
        $description = "from $($start.ToString('MMM dd, yyyy')) to $($end.ToString('MMM dd, yyyy'))"
    }
    else {
        # Hours back (default: 24)
        $hoursBack = if ($BoundParams.ContainsKey('Hours')) { $BoundParams['Hours'] } else { 24 }
        $start = $now.AddHours(-$hoursBack)
        
        if ($hoursBack -eq 24) {
            $description = "in the last 24 hours"
        } elseif ($hoursBack -lt 24) {
            $description = "in the last $hoursBack hours"
        } elseif ($hoursBack % 24 -eq 0) {
            $days = $hoursBack / 24
            $description = "in the last $days days"
        } else {
            $description = "in the last $hoursBack hours"
        }
    }
    
    # Validate date range
    if ($start -gt $end) {
        throw "Start date cannot be after end date"
    }
    
    $daysDiff = ($end - $start).TotalDays
    if ($daysDiff -gt 365) {
        throw "Date range cannot exceed 365 days"
    }
    
    return @{
        Start = $start
        End = $end
        Description = $description
        TotalDays = [Math]::Ceiling($daysDiff)
    }
}

function Show-Header {
    param(
        [hashtable]$DateRangeInfo,
        [string]$SearchTarget
    )
    
    Clear-Host
    Write-Host ""
    Write-ColorText "========================================================================" $colors.Header
    Write-ColorText "         MLB NEWS BY CLI - Search for Baseball News                    " $colors.Header
    Write-ColorText "========================================================================" $colors.Header
    Write-Host ""
    Write-ColorText "Searching for $SearchTarget $($DateRangeInfo.Description)" $colors.Info
    Write-ColorText "   ($($DateRangeInfo.Start.ToString('yyyy-MM-dd HH:mm')) to $($DateRangeInfo.End.ToString('yyyy-MM-dd HH:mm')))" $colors.Date
    Write-Host ""
}

function Get-MLBNews {
    param(
        [DateTime]$StartDate,
        [DateTime]$EndDate,
        [bool]$ShowVerbose,
        [string[]]$SourceTypes,
        [string]$Team,
        [string[]]$Players
    )
    
    Write-ColorText "Searching MLB news across multiple sources..." $colors.Info
    Write-Host ""
    
    $allNews = @()
    $totalArticlesChecked = 0
    $sourcesAttempted = 0
    $sourcesSuccessful = 0
    
    # Define all available search sources with their types
    $allSearchSources = @(
        @{
            Name = "MLB Trade News"
            Type = "Trade"
            Url = "https://news.google.com/rss/search?q=MLB+trade&hl=en-US&gl=US&ceid=US:en"
        },
        @{
            Name = "MLB Roster Moves"
            Type = "Roster"
            Url = "https://news.google.com/rss/search?q=MLB+roster+moves&hl=en-US&gl=US&ceid=US:en"
        },
        @{
            Name = "MLB Transactions"
            Type = "Transaction"
            Url = "https://news.google.com/rss/search?q=MLB+transaction&hl=en-US&gl=US&ceid=US:en"
        },
        @{
            Name = "MLB Signings"
            Type = "Signing"
            Url = "https://news.google.com/rss/search?q=MLB+sign+free+agent&hl=en-US&gl=US&ceid=US:en"
        },
        @{
            Name = "MLB Acquisitions"
            Type = "Acquisition"
            Url = "https://news.google.com/rss/search?q=MLB+acquire&hl=en-US&gl=US&ceid=US:en"
        },
        @{
            Name = "Baseball General News"
            Type = "General"
            Url = "https://news.google.com/rss/search?q=baseball+news&hl=en-US&gl=US&ceid=US:en"
        }
    )
    
    # Filter sources based on user selection
    $searchSources = @()
    if ($SourceTypes -contains 'All') {
        $searchSources = $allSearchSources
    } else {
        foreach ($source in $allSearchSources) {
            if ($SourceTypes -contains $source.Type) {
                $searchSources += $source
            }
        }
    }
    
    if ($searchSources.Count -eq 0) {
        Write-ColorText "No sources selected!" $colors.Error
        return @()
    }
    
    Write-ColorText "Selected sources: $($searchSources.Count) of $($allSearchSources.Count)" $colors.Info
    foreach ($source in $searchSources) {
        Write-ColorText "   * $($source.Name) ($($source.Type))" $colors.Info
    }
    Write-Host ""
    
    foreach ($source in $searchSources) {
        $sourcesAttempted++
        
        try {
            Write-ColorText "  -> Fetching: $($source.Name)..." $colors.Info
            
            # Fetch RSS feed with better error handling
            $response = Invoke-WebRequest -Uri $source.Url -TimeoutSec 15 -ErrorAction Stop -UseBasicParsing
            [xml]$rss = $response.Content
            
            if ($ShowVerbose) {
                Write-ColorText "      Response Status: $($response.StatusCode)" $colors.Info
            }
            
            # Try multiple RSS feed structures
            $items = $null
            
            # Standard RSS 2.0 structure
            if ($rss.rss.channel.item) {
                $items = $rss.rss.channel.item
                if ($ShowVerbose) {
                    Write-ColorText "      Feed Structure: Standard RSS 2.0" $colors.Info
                }
            }
            # Atom feed structure
            elseif ($rss.feed.entry) {
                $items = $rss.feed.entry
                if ($ShowVerbose) {
                    Write-ColorText "      Feed Structure: Atom" $colors.Info
                }
            }
            # Direct channel items (some feeds)
            elseif ($rss.channel.item) {
                $items = $rss.channel.item
                if ($ShowVerbose) {
                    Write-ColorText "      Feed Structure: Direct channel" $colors.Info
                }
            }
            
            if ($items -and $items.Count -gt 0) {
                $sourcesSuccessful++
                $itemsInSource = 0
                $matchingItems = 0
                
                foreach ($item in $items) {
                    $itemsInSource++
                    $totalArticlesChecked++
                    
                    try {
                        # Try to get publication date from various possible fields
                        $pubDate = $null
                        if ($item.pubDate) {
                            $pubDate = [DateTime]::Parse($item.pubDate)
                        } elseif ($item.published) {
                            $pubDate = [DateTime]::Parse($item.published)
                        } elseif ($item.updated) {
                            $pubDate = [DateTime]::Parse($item.updated)
                        } else {
                            # No date found, skip
                            continue
                        }
                        
                        # Add buffer to date range to catch more articles (6 hours before/after)
                        $dateBuffer = [TimeSpan]::FromHours(6)
                        $searchStart = $StartDate.Subtract($dateBuffer)
                        $searchEnd = $EndDate.Add($dateBuffer)
                        
                        if ($pubDate -ge $searchStart -and $pubDate -le $searchEnd) {
                            
                            # Get title from various possible fields
                            $title = ""
                            if ($item.title) {
                                if ($item.title -is [string]) {
                                    $title = $item.title
                                } elseif ($item.title.'#text') {
                                    $title = $item.title.'#text'
                                } else {
                                    $title = $item.title.ToString()
                                }
                            }
                            
                            if ([string]::IsNullOrWhiteSpace($title)) {
                                continue
                            }
                            
                            $titleLower = $title.ToLower()
                            
                            # Get description
                            $description = ""
                            if ($item.description) {
                                $description = $item.description
                            } elseif ($item.summary) {
                                $description = $item.summary
                            } elseif ($item.content) {
                                $description = $item.content
                            }
                            
                            if ($description -is [string]) {
                                $descriptionLower = $description.ToLower()
                            } else {
                                $descriptionLower = ""
                            }
                            
                            # Check if article matches team or player filters
                            $isRelevant = $false
                            $matchReason = ""
                            
                            # If no player specified, check team
                            if (-not $Players -or $Players.Count -eq 0) {
                                if ($Team -eq 'All') {
                                    $isRelevant = $true
                                    $matchReason = "General MLB news"
                                } else {
                                    if ($titleLower -match [regex]::Escape($Team.ToLower()) -or $descriptionLower -match [regex]::Escape($Team.ToLower())) {
                                        $isRelevant = $true
                                        $matchReason = "Matches team: $Team"
                                    }
                                }
                            } else {
                                # Check for player mentions
                                foreach ($playerName in $Players) {
                                    if ($titleLower -match [regex]::Escape($playerName.ToLower()) -or $descriptionLower -match [regex]::Escape($playerName.ToLower())) {
                                        $isRelevant = $true
                                        $matchReason = "Matches player: $playerName"
                                        break
                                    }
                                }
                            }
                            
                            # Also check for trade-related keywords
                            if ($isRelevant) {
                                $tradeKeywords = @(
                                    'trade', 'deal', 'acquire', 'sign', 'roster', 'move', 'transaction',
                                    'swap', 'exchange', 'claim', 'designate', 'option', 'waive', 'waived',
                                    'release', 'placed on', 'recalled', 'sent to', 'promoted', 'called up',
                                    'optioned', 'designated', 'injured list', 'IL', 'DFA', 'free agent',
                                    'contract', 'extension', 'agreement', 'terms', 'added', 'removed',
                                    'assigned', 'outrighted', 'selected', 'purchased', 'transferred',
                                    'draft', 'signing', 'agreement'
                                )
                                
                                $isTradeRelated = $false
                                foreach ($keyword in $tradeKeywords) {
                                    if ($titleLower -match $keyword -or $descriptionLower -match $keyword) {
                                        $isTradeRelated = $true
                                        break
                                    }
                                }
                                
                                if ($isTradeRelated) {
                                    $matchingItems++
                                    
                                    # Extract source
                                    $sourceText = "Unknown"
                                    if ($item.source -and $item.source.'#text') {
                                        $sourceText = $item.source.'#text'
                                    } elseif ($item.author) {
                                        $sourceText = $item.author
                                    } elseif ($item.link) {
                                        try {
                                            # Get link - could be string or object
                                            $linkUrl = ""
                                            if ($item.link -is [string]) {
                                                $linkUrl = $item.link
                                            } elseif ($item.link.href) {
                                                $linkUrl = $item.link.href
                                            }
                                            
                                            if ($linkUrl) {
                                                $uri = [System.Uri]$linkUrl
                                                $sourceText = $uri.Host -replace '^www\.', ''
                                            }
                                        } catch {
                                            $sourceText = "Unknown"
                                        }
                                    }
                                    
                                    # Get link
                                    $linkUrl = ""
                                    if ($item.link -is [string]) {
                                        $linkUrl = $item.link
                                    } elseif ($item.link.href) {
                                        $linkUrl = $item.link.href
                                    } elseif ($item.link.'#text') {
                                        $linkUrl = $item.link.'#text'
                                    }
                                    
                                    $newsItem = [PSCustomObject]@{
                                        Title = $title
                                        Link = $linkUrl
                                        Source = $sourceText
                                        PubDate = $pubDate
                                        Description = $description
                                        MatchReason = $matchReason
                                    }
                                    $allNews += $newsItem
                                    
                                    if ($ShowVerbose) {
                                        Write-ColorText "      + Match: $title" $colors.Success
                                        Write-ColorText "        Reason: $matchReason | Date: $($pubDate.ToString('MMM dd HH:mm'))" $colors.Date
                                    }
                                }
                            }
                        }
                    }
                    catch {
                        # Skip items with parsing errors
                        if ($ShowVerbose) {
                            Write-ColorText "      - Skipped item due to error: $($_.Exception.Message)" $colors.Error
                        }
                        continue
                    }
                }
                
                Write-ColorText "      Retrieved $itemsInSource articles, $matchingItems matched criteria" $colors.Info
            }
            else {
                Write-ColorText "      No items found in RSS feed" $colors.Error
                if ($ShowVerbose) {
                    Write-ColorText "      Feed root element: $($rss.DocumentElement.Name)" $colors.Info
                    Write-ColorText "      Response length: $($response.Content.Length) bytes" $colors.Info
                }
            }
            
            Start-Sleep -Milliseconds 400  # Rate limiting
        }
        catch {
            Write-ColorText "      ERROR: $($_.Exception.Message)" $colors.Error
            if ($ShowVerbose) {
                Write-ColorText "      Full error: $($_.Exception.ToString())" $colors.Error
            }
        }
    }
    
    Write-Host ""
    Write-ColorText "Search Summary:" $colors.Header
    Write-ColorText "   Sources attempted: $sourcesAttempted" $colors.Info
    Write-ColorText "   Sources successful: $sourcesSuccessful" $colors.Success
    Write-ColorText "   Total articles checked: $totalArticlesChecked" $colors.Info
    Write-ColorText "   Articles matching criteria: $($allNews.Count)" $colors.Success
    
    # Remove duplicates based on title similarity and link
    $uniqueNews = @()
    $seenTitles = @{}
    $seenLinks = @{}
    
    foreach ($news in ($allNews | Sort-Object PubDate -Descending)) {
        # Normalize title for comparison
        $titleKey = $news.Title -replace '[^\w\s]', '' -replace '\s+', ' '
        $titleKey = $titleKey.Trim().ToLower()
        
        $linkKey = $news.Link
        
        if (-not $seenTitles.ContainsKey($titleKey) -and -not $seenLinks.ContainsKey($linkKey)) {
            $seenTitles[$titleKey] = $true
            $seenLinks[$linkKey] = $true
            $uniqueNews += $news
        }
    }
    
    if ($allNews.Count -gt $uniqueNews.Count) {
        Write-ColorText "   Duplicates removed: $($allNews.Count - $uniqueNews.Count)" $colors.Info
    }
    Write-ColorText "   Final unique articles: $($uniqueNews.Count)" $colors.Success
    Write-Host ""
    
    return $uniqueNews | Sort-Object PubDate -Descending
}

function Show-NewsItem {
    param([PSCustomObject]$NewsItem, [int]$Index)
    
    Write-ColorText "[$Index] " $colors.Header -NoNewline
    Write-ColorText $NewsItem.Title $colors.Title
    
    Write-ColorText "    Published: " $colors.Info -NoNewline
    Write-ColorText $NewsItem.PubDate.ToString("yyyy-MM-dd HH:mm:ss") $colors.Date
    
    Write-ColorText "    Source: " $colors.Info -NoNewline
    Write-ColorText $NewsItem.Source $colors.Source
    
    Write-ColorText "    Match: " $colors.Info -NoNewline
    Write-ColorText $NewsItem.MatchReason $colors.Info
    
    Write-ColorText "    Link: " $colors.Info -NoNewline
    Write-ColorText $NewsItem.Link $colors.Info
    
    Write-Host ""
    Write-ColorText ("=" * 80) $colors.Separator
    Write-Host ""
}

function Show-Summary {
    param(
        [array]$News,
        [hashtable]$DateRangeInfo
    )
    
    if ($News.Count -eq 0) {
        Write-ColorText "No relevant MLB news found $($DateRangeInfo.Description)" $colors.Error
        Write-Host ""
        Write-ColorText "This could mean:" $colors.Info
        Write-ColorText "  * No trades or roster moves were announced during this period" $colors.Info
        Write-ColorText "  * News sources haven't reported on moves yet (try a wider date range)" $colors.Info
        Write-ColorText "  * The date range might be too narrow or in the past" $colors.Info
        if ($DateRangeInfo.TotalDays -gt 30) {
            Write-ColorText "  * Try searching a more recent date range for better results" $colors.Info
        }
        Write-Host ""
        Write-ColorText "Tips:" $colors.Header
        Write-ColorText "  * Use -VerboseOutput to see detailed search information" $colors.Info
        Write-ColorText "  * Try searching last 7-14 days: -Hours 168 or -Hours 336" $colors.Info
        Write-ColorText "  * MLB news is most active during:" $colors.Info
        Write-ColorText "    - Trade deadline (late July - early August)" $colors.Info
        Write-ColorText "    - Free agency (November - February)" $colors.Info
        Write-ColorText "    - Spring training (February - March)" $colors.Info
    } else {
        Write-ColorText "Found $($News.Count) relevant news item(s) $($DateRangeInfo.Description)" $colors.Success
        
        # Show date distribution
        if ($News.Count -gt 1) {
            $oldestNews = $News | Sort-Object PubDate | Select-Object -First 1
            $newestNews = $News | Sort-Object PubDate -Descending | Select-Object -First 1
            Write-ColorText "   Date range of results:" $colors.Info
            Write-ColorText "      Oldest: $($oldestNews.PubDate.ToString('MMM dd, yyyy HH:mm'))" $colors.Date
            Write-ColorText "      Newest: $($newestNews.PubDate.ToString('MMM dd, yyyy HH:mm'))" $colors.Date
        }
    }
    Write-Host ""
}

# Main execution
try {
    # Build search target description
    $searchTarget = ""
    if ($Player -and $Player.Count -gt 0) {
        $searchTarget = "for $($Player -join ', ')"
    } elseif ($Team -ne 'All') {
        $searchTarget = "for $Team"
    } else {
        $searchTarget = "MLB news"
    }
    
    # Determine date range based on parameters
    $dateRange = Get-DateRange -BoundParams $PSBoundParameters
    
    Show-Header -DateRangeInfo $dateRange -SearchTarget $searchTarget
    
    Write-ColorText "Date range spans $($dateRange.TotalDays) day(s)" $colors.Info
    if ($VerboseOutput) {
        Write-ColorText "Verbose mode enabled - showing detailed search information" $colors.Info
    }
    if ($Sources -and -not ($Sources -contains 'All')) {
        Write-ColorText "Filtering sources: $($Sources -join ', ')" $colors.Info
    }
    Write-Host ""
    
    $news = Get-MLBNews -StartDate $dateRange.Start -EndDate $dateRange.End -ShowVerbose $VerboseOutput -SourceTypes $Sources -Team $Team -Players $Player
    
    Show-Summary -News $news -DateRangeInfo $dateRange
    
    if ($news.Count -gt 0) {
        Write-ColorText "========== NEWS ARTICLES ==========" $colors.Header
        Write-Host ""
        
        for ($i = 0; $i -lt $news.Count; $i++) {
            Show-NewsItem -NewsItem $news[$i] -Index ($i + 1)
        }
    }
    
    Write-Host ""
    Write-ColorText "========================================================================" $colors.Separator
    Write-ColorText "Press any key to exit..." $colors.Info
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
catch {
    Write-Host ""
    Write-ColorText "========================================================================" $colors.Separator
    Write-ColorText "ERROR OCCURRED" $colors.Error
    Write-ColorText "========================================================================" $colors.Separator
    Write-Host ""
    Write-ColorText "Error Message:" $colors.Error
    Write-ColorText $_.Exception.Message $colors.Error
    Write-Host ""
    Write-ColorText "Stack Trace:" $colors.Error
    Write-ColorText $_.ScriptStackTrace $colors.Error
    Write-Host ""
    Write-ColorText "Press any key to exit..." $colors.Info
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
