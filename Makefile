
all : 
	@echo "Running all tests..."
	forge test

bank_test:
	@echo "Running bank test..."
	forge test --match-contract BankTest

game_test :
	@echo "Running game test..."
	forge test --match-contract GameTest

