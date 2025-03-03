
all : 
	@echo "Running all tests..."
	forge test

bank_test:
	@echo "Running bank test..."
	forge test --match-contract BankTest

game_test :
	clear
	@echo "Running game test..."
	forge test --match-contract GameTest

bank_player_owned :
	@echo "Running bank player owned properties test..."
	forge t --match-contract BankTest --match-test testGetPropertiesOwnerByAPlayer

entry_point :
	@echo "running test on account_abstraction via EntryPoint contract"
	forge t --match-contract EntryPointTest

player_entry_point:
	@echo "player entry point test"
	forge t --match-contract PlayerEntryPointTest
