
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

player_smart_account:
	@echo "player entry point test"
	forge t --match-contract PlayerSmartAccountTest

game_entry_point:
	@echo "running game via entry point"
	forge t --match-contract GameTest

deploy_nft_contract:
	@echo "adding the environment variables to the console"
	source .env
	forge script script/NFTContract.s.sol:NFTContract --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast

deploy_bank_factory:
	@echo "deploying the bank factory contract"
#	source .env
#	@echo "environment variables added to the console"
	forge script script/BankFactory.s.sol:BankFactoryScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast

interact_with_bank:
	@echo ""
	forge script script/GameBank.s.sol:GameBankScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
confirm_deploy:
	@echo ""
	cast code $CONTRACT_ADDRESS --rpc-url $RPC_URL
