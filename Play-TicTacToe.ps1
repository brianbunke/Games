function Play-TicTacToe {

<#
.SYNOPSIS
A simple Tic-Tac-Toe game.

.DESCRIPTION
Created 2015/09/20 to practice PowerShell. Basic functions, Do/While,
script-scope variables, and manipulating context-sensitive variables.

.NOTES
Brian Bunke
https://twitter.com/brianbunke
https://github.com/brianbunke
http://brianbunke.com

.EXAMPLE
. .\Play-TicTacToe.ps1 ; Play-TicTacToe
Dot-source the function, begin a new game.
#>

    # Create a repeatable function to update/draw the board
    function Update-Board {
        # Skip this if someone has already won
        If ($Winner -ne $true) {
# Refresh the board with the new turn's input, then display it again
# Can't get the here string @" "@ to work tabbed in, just collapsing it in the ISE instead
( $Board = @"

$1 | $2 | $3
---------
$4 | $5 | $6
---------
$7 | $8 | $9

"@ ) | Write-Output
        }
    }

    # Create a repeatable function to prompt for input and apply it to the board
    function Take-Turn {
        # If somebody has already won, we don't need to take more turns
        If ($Winner -eq $true) {}
        # Player 1, aka Player O
        ElseIf ($Turn -eq 1) {
            [int]$OTurn = Read-Host 'Player O, choose a position from 1-9'
            # Verify that the player selected an empty square
            If ((Get-Variable -Name $OTurn).Value -eq ' ') {
                 # Set a context-sensitive variable with Player 1's letter O
                 Set-Variable -Name $OTurn -Value 'O' -Scope Script
                 # Change the turn
                 $script:Turn = 2
            }
            Else {
                Write-Output 'You lose your turn for not matching an empty square.'
                # Undo this as counting against the nine total turns
                $script:Z--
                # Change the turn
                $script:Turn = 2
            }
        }
        # Player 2, aka Player X
        Else {
            [int]$XTurn = Read-Host 'Player X, choose a position from 1-9'
            # Verify that the player selected an empty square
            If ((Get-Variable -Name $XTurn).Value -eq ' ') {
                 # Set a context-sensitive variable with Player 2's letter X
                 Set-Variable -Name $XTurn -Value 'X' -Scope Script
                 # Change the turn
                 $script:Turn = 1
            }
            Else {
                Write-Output 'You lose your turn for not matching an empty square.'
                # Undo this as counting against the nine total turns
                $script:Z--
                # Change the turn
                $script:Turn = 1
            }
        }
    }

    # Create a repeatable function to evaluate the board
    function Check-Winner {
        # If somebody has already won, we don't need to redo this check
        If ($Winner -ne $true) {
        # Group wins together in a way that you don't need 8 if/elseifs
            # Group orthogonal $1 wins
            If ( (($1 -eq $2 -and $2 -eq $3) -or ($1 -eq $4 -and $4 -eq $7)) -and ($1 -ne ' ') ) {
                Write-Output "### Player $1 is the winner! ###"
                $script:Winner = $true
            }
            # Group all the middle square wins together
            ElseIf ( (($1 -eq $5 -and $5 -eq $9) -or ($2 -eq $5 -and $5 -eq $8) -or
                       ($3 -eq $5 -and $5 -eq $7) -or ($4 -eq $5 -and $5 -eq $6)) -and ($5 -ne ' ') ) {
                Write-Output "### Player $5 is the winner! ###"
                $script:Winner = $true
            }
            # Group orthogonal $9 wins
            ElseIf ( (($3 -eq $6 -and $6 -eq $9) -or ($7 -eq $8 -and $8 -eq $9)) -and ($9 -ne ' ') ) {
                Write-Output "### Player $9 is the winner! ###"
                $script:Winner = $true
            }
        }
    }

    # Using $script:Winner was preventing subsequent plays in the same window
    $script:Winner = $null
    # Set $1 - $9 to ' ' to space the grid properly
    1..9 | % {Set-Variable -Name "$_" -Value ' ' -Scope Script}
    # Number 0 vs. letter O are super confusing, so let's stick to 1 vs. 2
    $script:Turn = 1..2 | Get-Random
    # Draw the board before the first turn
    Update-Board

    # Increment through the game's turns until there is a winner
    $script:Z = 1
    DO {
        Take-Turn
        Update-Board
        Check-Winner
        $script:Z++
    } WHILE ( $Z -le 9 )

    If ($Winner -ne $true) {
        Write-Output '### GAME ENDS IN A DRAW ###'
    }
}