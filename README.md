# CorePoly - A Monopoly Game on-chain
## Overview
A decentralized Monopoly game implemented as a Solidity smart contract. The game is designed to be played entirely on-chain, enforcing game rules through smart contract logic.

![Screenshot from 2025-02-24 00-41-38](https://github.com/user-attachments/assets/62db6a67-8a16-4f74-9de9-ee3fedf2bf9d)

### Purpose:
* Blockchain Gaming Adoption: Drive the adoption of blockchain technology by showcasing its practical application through gaming. 
* Digital assets engagement: Engagement with unique digital assets such as NFTs to enhance gameplay. 

 ### Network & Deployment: Core Blockchain

### Technologies Used
* Solidity
* Hardhat
* Foundry
* OpenZeppelin
* React.js
* Project Overview and Gameplay

### This project integrates several components to deliver a digital board game experience. 

At the start of a Monopoly game, several key events and setups occur to initialize the game. Here's a breakdown of what typically happens: 
Setup the Board and Components Place Properties and Cards: The game board is arranged with properties, Chance cards, and Community Chest cards in their respective positions. Allocate Tokens: Each player selects a token (e.g., car, hat, dog) to represent them on the board. 
Distribute Starting Money Each player receives a predefined amount of starting money, typically: 2 x $500 4 x $100 1 x $50 1 x $20 2 x $10 1 x $5 5 x $1 The bank is set up to manage the rest of the money, properties, and houses/hotels. 
Decide the Turn Order All players roll the dice to determine the turn order. The player with the highest roll goes first. 
Place Players in the Starting Position All players place their tokens on the "GO" square. 
Game Rules and Starting Events Game Rules: The banker or a designated player explains the rules to ensure everyone is on the same page. Initial Turns: On each player's turn: Roll two six-sided dice. Move the number of spaces indicated on the dice. Take actions based on the space landed on (e.g., buying properties, paying rent, drawing a Chance card). 
Bank Responsibilities: The bank handles transactions such as collecting fines and taxes and selling properties. Managing houses, hotels, and mortgages. Paying players $200 every time they pass "GO." 
First Moves Players start taking turns, rolling dice, and progressing through the board. They can: Buy unowned properties. Pay rent if landing on an owned property. Draw a Chance or Community Chest card if landing on those spaces. Go to jail if landing on the "Go to Jail" space or drawing a card instructing them to do so.

### Contract Architecture
Smart Contracts
* MonopolyLibrary.sol: Serves as a utility library to the Monopoly game smart contracts. It defines essential data structures and emits relevant events for tracking in-game actions.
* Bank.sol: Manages the game economy, utilizing ERC20 token. It is a helper contract that will be deployed upon the creation of every new game.
* Counter.sol: Allows players to store and modify a number
* Dice.sol: Simulates the rolling of two six-sided dice. The randomness is derived from block.timestamp.
* Game.sol: This is the main contract, which handles the game's core mechanics. 
* NFT.sol: This is another helper contract which manages the NFTs utilized within the game.
* Players.sol: This is another helper contract that manages the players, the properties, and property transactions within the game.

![Screenshot from 2025-02-24 00-39-56](https://github.com/user-attachments/assets/51f8a2a5-5611-4b71-8697-d553b8903f4d)


### Economy & Tokens
* Currency: ERC20 Standard
* Properties: Represented as NFTs - ERC721 standard
* Bankruptcy Handling: Players are eliminated when funds reach zero.
