# MLB News By CLI

A PowerShell CLI application that searches for and displays MLB news with flexible filtering options. Search by team, specific players, date ranges, and news types.

## Features

- Search MLB news for any team or all teams
- Search news about specific players or multiple players
- Flexible date filtering with multiple options:
  - **Hours back** (1-8760 hours / up to 1 year)
  - **Specific date** (search news from a particular day)
  - **Custom date range** (search between any two dates)
- Filter by news type (Trade, Roster, Transaction, Signing, Acquisition, General, or All)
- Color-coded terminal output for better readability
- Displays article titles, publication dates, sources, and links
- Removes duplicate articles automatically
- Shows distribution of articles across the date range
- Verbose mode for debugging and detailed search information
- Searches across multiple RSS sources for comprehensive coverage

## What's Included

- `mlb-news-by-cli.ps1` - Main script
- `README.md` - This documentation file

## Requirements

- PowerShell 5.1 or higher (Windows)
- PowerShell Core 7+ (Windows, macOS, Linux)
- Internet connection for RSS feed access

## Installation

1. Download the `mlb-news-by-cli.ps1` file
2. Open PowerShell or PowerShell Core
3. Navigate to the directory containing the script

### Windows PowerShell Execution Policy

If you encounter execution policy errors on Windows, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Quick Start

### Search All MLB News (Last 24 Hours)
```powershell
./mlb-news-by-cli.ps1
```

### Search Specific Team
```powershell
# Yankees news
./mlb-news-by-cli.ps1 -Team Yankees

# Dodgers news
./mlb-news-by-cli.ps1 -Team Dodgers

# Red Sox news
./mlb-news-by-cli.ps1 -Team "Red Sox"
```

### Search Specific Player
```powershell
# Juan Soto news
./mlb-news-by-cli.ps1 -Player "Juan Soto"

# Multiple players
./mlb-news-by-cli.ps1 -Player "Juan Soto","Aaron Judge"
```

## Usage Examples

### By Team

#### Search Only Trades
```powershell
./mlb-news-by-cli.ps1 -Team Yankees -Sources Trade
```

#### Search Only Signings
```powershell
./mlb-news-by-cli.ps1 -Team "Red Sox" -Sources Signing
```

#### Search Multiple News Types
```powershell
./mlb-news-by-cli.ps1 -Team Dodgers -Sources Trade,Signing
```

### By Player

#### Single Player
```powershell
./mlb-news-by-cli.ps1 -Player "Shohei Ohtani"
```

#### Multiple Players
```powershell
./mlb-news-by-cli.ps1 -Player "Mike Trout","Mookie Betts"
```

#### Player + Team Combination
```powershell
./mlb-news-by-cli.ps1 -Player "Aaron Judge" -Team Yankees -Sources Trade
```

### By Date Range

#### Last 7 Days
```powershell
./mlb-news-by-cli.ps1 -Hours 168

# Or with team filter
./mlb-news-by-cli.ps1 -Team Yankees -Hours 168
```

#### Last 30 Days
```powershell
./mlb-news-by-cli.ps1 -Hours 720
```

#### Specific Date
```powershell
./mlb-news-by-cli.ps1 -Date "2025-11-15"

# Or with player filter
./mlb-news-by-cli.ps1 -Player "Juan Soto" -Date "2025-11-15"
```

#### Custom Date Range
```powershell
# Trade deadline period
./mlb-news-by-cli.ps1 -StartDate "2025-07-20" -EndDate "2025-08-05" -Sources Trade

# Free agency period
./mlb-news-by-cli.ps1 -StartDate "2025-11-01" -EndDate "2025-12-31" -Sources Signing
```

### Verbose Mode

#### Debug Search Information
```powershell
./mlb-news-by-cli.ps1 -Team Yankees -VerboseOutput

# With player search
./mlb-news-by-cli.ps1 -Player "Mike Trout" -VerboseOutput

# With date range
./mlb-news-by-cli.ps1 -Hours 168 -VerboseOutput
```

### Complex Examples

#### Trade Deadline Monitoring
```powershell
# Search for all trades during deadline period
./mlb-news-by-cli.ps1 -StartDate "2025-07-20" -EndDate "2025-08-05" -Sources Trade

# Search specific team during deadline
./mlb-news-by-cli.ps1 -Team Yankees -StartDate "2025-07-20" -EndDate "2025-08-05" -Sources Trade
```

#### Free Agency Tracking
```powershell
# Track all signings in free agency period
./mlb-news-by-cli.ps1 -StartDate "2025-11-01" -EndDate "2025-12-31" -Sources Signing

# Track specific team signings
./mlb-news-by-cli.ps1 -Team "Red Sox" -StartDate "2025-11-01" -EndDate "2025-12-31" -Sources Signing
```

#### Spring Training Monitoring
```powershell
# Monitor roster moves during spring training
./mlb-news-by-cli.ps1 -StartDate "2025-02-15" -EndDate "2025-03-26" -Sources Roster
```

#### Player Transaction Tracking
```powershell
# Track all news about a player
./mlb-news-by-cli.ps1 -Player "Shohei Ohtani" -Hours 720

# Track with verbose output to see details
./mlb-news-by-cli.ps1 -Player "Juan Soto" -VerboseOutput

# Track specific transaction types
./mlb-news-by-cli.ps1 -Player "Aaron Judge" -Sources Transaction,Acquisition
```

## Parameters Reference

### `-Team`
Select which MLB team to search for.

**Type:** String  
**Default:** 'All' (searches all teams)  
**Options:** All, Diamondbacks, Braves, Orioles, Red Sox, Cubs, White Sox, Reds, Guardians, Rockies, Tigers, Astros, Royals, Angels, Dodgers, Marlins, Brewers, Twins, Mets, Yankees, Athletics, Phillies, Pirates, Padres, Giants, Mariners, Cardinals, Rays, Rangers, Blue Jays, Nationals

**Examples:**
```powershell
-Team Yankees
-Team Dodgers
-Team "Red Sox"
```

### `-Player`
Search for one or more specific players.

**Type:** String array  
**Default:** (none)  
**Multiple players:** Use comma-separated values

**Examples:**
```powershell
-Player "Juan Soto"
-Player "Juan Soto","Aaron Judge"
-Player "Mike Trout"
```

### `-Hours`
Number of hours to look back for news.

**Type:** Integer (1-8760)  
**Default:** 24  
**Max:** 8760 hours (1 year)

**Examples:**
```powershell
-Hours 24      # Last 24 hours
-Hours 168     # Last 7 days
-Hours 720     # Last 30 days
-Hours 2160    # Last 90 days
```

### `-Date`
Search for news on a specific date (searches the entire day).

**Type:** DateTime  
**Format:** Supports multiple formats

**Examples:**
```powershell
-Date "2025-11-15"
-Date "November 15, 2025"
-Date "11/15/2025"
-Date (Get-Date).AddDays(-7)
```

### `-StartDate`
Start date for custom date range.

**Type:** DateTime  
**Default:** 30 days before EndDate if only EndDate provided

**Examples:**
```powershell
-StartDate "2025-11-01"
-StartDate "2025-07-20"
```

### `-EndDate`
End date for custom date range.

**Type:** DateTime  
**Default:** Today  
**Max range:** 365 days

**Examples:**
```powershell
-EndDate "2025-11-15"
-EndDate "2025-08-05"
```

### `-Sources`
Select which types of news to search.

**Type:** String array  
**Default:** 'All'  
**Options:** Trade, Roster, Transaction, Signing, Acquisition, General, All  
**Multiple sources:** Use comma-separated values

**Examples:**
```powershell
-Sources Trade
-Sources Signing
-Sources Trade,Signing
-Sources Trade,Roster,Transaction
-Sources All      # Explicit (same as default)
```

**Source Types Explained:**
- **Trade** - Trade news and deals between teams
- **Roster** - Roster moves, call-ups, send-downs
- **Transaction** - DFA, waiver claims, options
- **Signing** - New player signings and contracts
- **Acquisition** - Player acquisitions (trades, claims)
- **General** - General baseball news
- **All** - All of the above

### `-VerboseOutput`
Enable verbose output to see detailed search information.

**Type:** Switch flag  
**Default:** Disabled

**What it shows:**
- Each article as it's discovered
- Which keywords matched
- Article timestamps
- Detailed error messages
- Full search statistics

**Examples:**
```powershell
-VerboseOutput
./mlb-news-by-cli.ps1 -Team Yankees -VerboseOutput
./mlb-news-by-cli.ps1 -Player "Mike Trout" -VerboseOutput
```

## Parameter Combinations

### Valid Parameter Combinations

You can combine parameters flexibly:

```powershell
# Team + Date options
./mlb-news-by-cli.ps1 -Team Yankees -Hours 168
./mlb-news-by-cli.ps1 -Team Dodgers -Date "2025-11-15"
./mlb-news-by-cli.ps1 -Team "Red Sox" -StartDate "2025-11-01" -EndDate "2025-11-15"

# Player + Date options
./mlb-news-by-cli.ps1 -Player "Juan Soto" -Hours 720
./mlb-news-by-cli.ps1 -Player "Aaron Judge" -Date "2025-11-15"
./mlb-news-by-cli.ps1 -Player "Mike Trout" -StartDate "2025-07-01" -EndDate "2025-08-31"

# Team/Player + Sources
./mlb-news-by-cli.ps1 -Team Yankees -Sources Trade
./mlb-news-by-cli.ps1 -Player "Juan Soto" -Sources Signing
./mlb-news-by-cli.ps1 -Team Dodgers -Sources Trade,Signing,Roster

# Everything combined
./mlb-news-by-cli.ps1 -Team Yankees -Sources Trade -Hours 168 -VerboseOutput
./mlb-news-by-cli.ps1 -Player "Mike Trout" -StartDate "2025-07-01" -EndDate "2025-08-31" -Sources Acquisition -VerboseOutput
```

### Parameter Set Rules

- **Date options:** You can use only ONE of these:
  - `-Hours` (searches back from now)
  - `-Date` (searches a specific day)
  - `-StartDate` and/or `-EndDate` (custom range)
- **Team and Player:** Can be used together or separately
- **Sources:** Can be combined with any date option
- **VerboseOutput:** Can be combined with any options
- **If no date parameter:** Defaults to `-Hours 24` (last 24 hours)
- **Max date range:** 365 days

## Sample Output

### Successful Search
```
========================================================================
         MLB NEWS BY CLI - Search for Baseball News                    
========================================================================

Searching for Yankees news in the last 24 hours
   (2025-11-20 10:30 to 2025-11-21 10:30)

Date range spans 1 day(s)

Searching MLB news across multiple sources...

Selected sources: 6 of 6
   * MLB Trade News (Trade)
   * MLB Roster Moves (Roster)
   * MLB Transactions (Transaction)
   * MLB Signings (Signing)
   * MLB Acquisitions (Acquisition)
   * Baseball General News (General)

  -> Fetching: MLB Trade News...
      Retrieved 98 articles, 3 matched criteria
  -> Fetching: MLB Roster Moves...
      Retrieved 87 articles, 2 matched criteria

Search Summary:
   Sources attempted: 6
   Sources successful: 6
   Total articles checked: 562
   Articles matching criteria: 5
   Final unique articles: 5

Found 5 relevant news item(s) in the last 24 hours
   Date range of results:
      Oldest: Nov 20, 2025 14:30
      Newest: Nov 21, 2025 09:15

========== NEWS ARTICLES ==========

[1] Yankees Sign Free Agent Pitcher
    Published: 2025-11-21 09:15:22
    Source: MLB.com
    Match: Matches team: Yankees
    Link: https://www.mlb.com/news/article/...

================================================================================
Press any key to exit...
```

### No Results Found
```
========================================================================
         MLB NEWS BY CLI - Search for Baseball News                    
========================================================================

Searching for Yankees news in the last 24 hours
   (2025-11-20 10:30 to 2025-11-21 10:30)

Date range spans 1 day(s)

Searching MLB news across multiple sources...

Selected sources: 6 of 6
   * MLB Trade News (Trade)
   * MLB Roster Moves (Roster)
   * MLB Transactions (Transaction)
   * MLB Signings (Signing)
   * MLB Acquisitions (Acquisition)
   * Baseball General News (General)

No relevant MLB news found in the last 24 hours

This could mean:
  * No trades or roster moves were announced during this period
  * News sources haven't reported on moves yet (try a wider date range)
  * The date range might be too narrow or in the past

Tips:
  * Use -VerboseOutput to see detailed search information
  * Try searching last 7-14 days: -Hours 168 or -Hours 336
  * MLB news is most active during:
    - Trade deadline (late July - early August)
    - Free agency (November - February)
    - Spring training (February - March)
```

## Troubleshooting

### Script Not Finding Any News

#### Step 1: Use Verbose Mode
```powershell
./mlb-news-by-cli.ps1 -Team Yankees -VerboseOutput
```
This shows detailed information about what the script is searching and finding.

#### Step 2: Try Different Date Ranges
```powershell
# Try last week instead of last 24 hours
./mlb-news-by-cli.ps1 -Team Yankees -Hours 168

# Try last 30 days
./mlb-news-by-cli.ps1 -Team Yankees -Hours 720

# Try trade deadline period
./mlb-news-by-cli.ps1 -Team Yankees -StartDate "2025-07-20" -EndDate "2025-08-05"
```

#### Step 3: Expand Search Scope
```powershell
# Search all teams
./mlb-news-by-cli.ps1 -Hours 168

# Search with all sources
./mlb-news-by-cli.ps1 -Team Yankees -Sources All
```

### Common Issues and Solutions

#### "No news found in last 24 hours"
**This is often normal!** News doesn't happen every day.
- Try searching last 7 days: `./mlb-news-by-cli.ps1 -Hours 168`
- Use verbose mode to see what's being found: `-VerboseOutput`
- Search during active periods (trade deadline, free agency)

#### RSS Feed Access Issues
**Cause:** Network restrictions or firewall blocking Google News  
**Solution:**
- Check your internet connection
- Check firewall settings
- Try running from a different network
- Google News feeds may be temporarily unavailable

#### Player Not Found
**Cause:** Player name spelling or nickname differences  
**Solution:**
- Check spelling carefully
- Try first name + last name: `"Juan Soto"`
- Use exact spelling as reported in news
- Search entire team if player name is ambiguous

#### Date Range Errors
```
Error: Start date cannot be after end date
```
Make sure StartDate is before EndDate.

```
Error: Date range cannot exceed 365 days
```
Maximum search range is 1 year. Break into smaller ranges.

### Connection Issues

- Check your internet connection
- Some news sources may be temporarily unavailable
- The script continues with other sources if one fails
- Try again in a few moments if sources are temporarily down

### Execution Policy Error (Windows)

Run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## How It Works

1. **Flexible Search:** Specify team, player, or both
2. **Date Range:** Choose how far back to search
3. **Source Filtering:** Select news types or search all
4. **RSS Feeds:** Fetches news from multiple MLB news sources
5. **Keyword Matching:** Filters articles by relevant keywords
6. **Duplicate Removal:** Ensures each story appears only once
7. **Display:** Shows formatted results with titles, dates, sources, and links

## Performance Tips

- **Faster searches:** Use specific team instead of 'All'
- **Faster searches:** Filter by source type (e.g., `-Sources Trade`)
- **Faster searches:** Use smaller date ranges when possible
- **Better results:** Search during active MLB periods (deadline, free agency)
- **Debug issues:** Use `-VerboseOutput` to see what's happening

## Available MLB Teams

| AL East | AL Central | AL West |
|---------|-----------|---------|
| Orioles | White Sox | Angels |
| Red Sox | Guardians | Astros |
| Rays | Royals | Athletics |
| Blue Jays | Tigers | Mariners |
| Yankees | Twins | Rangers |

| NL East | NL Central | NL West |
|---------|-----------|---------|
| Braves | Brewers | Diamondbacks |
| Marlins | Cardinals | Dodgers |
| Mets | Cubs | Giants |
| Nationals | Pirates | Padres |
| Phillies | Reds | Rockies |

## Notes

- The script uses publicly available RSS feeds
- News availability depends on what's published by news sources
- Links open articles in your default web browser
- No API keys or authentication required
- Searches are case-insensitive

## Platform Compatibility

| Platform | PowerShell Version | Status |
|----------|-------------------|--------|
| Windows 10/11 | 5.1+ | Supported |
| Windows 10/11 | Core 7+ | Supported |
| macOS | Core 7+ | Supported |
| Linux | Core 7+ | Supported |

## Help and Support

### Get Help in PowerShell
```powershell
Get-Help ./mlb-news-by-cli.ps1
Get-Help ./mlb-news-by-cli.ps1 -Detailed
Get-Help ./mlb-news-by-cli.ps1 -Examples
```

### Common Use Cases

**I want Yankees trade news:**
```powershell
./mlb-news-by-cli.ps1 -Team Yankees -Sources Trade
```

**I want to see what Shohei Ohtani is doing:**
```powershell
./mlb-news-by-cli.ps1 -Player "Shohei Ohtani"
```

**I want to monitor free agency:**
```powershell
./mlb-news-by-cli.ps1 -StartDate "2025-11-01" -EndDate "2025-12-31" -Sources Signing
```

**I want to track the trade deadline:**
```powershell
./mlb-news-by-cli.ps1 -StartDate "2025-07-20" -EndDate "2025-08-05" -Sources Trade -VerboseOutput
```

**I want to check multiple players:**
```powershell
./mlb-news-by-cli.ps1 -Player "Juan Soto","Aaron Judge"
```

## License

Free to use and modify for personal use.

## Version

**MLB News By CLI v1.0**

Last Updated: November 2025
