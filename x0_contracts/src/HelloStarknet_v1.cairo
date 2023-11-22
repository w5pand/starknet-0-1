#[starknet::interface]
trait IHelloStarknet<TContractState> {
    fn increase_balance(ref self: TContractState, amount: felt252);
    fn get_balance(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod HelloStarknet {
    use openzeppelin::upgrades::Upgradeable as upgradeable_component;
    use openzeppelin::upgrades::interface::IUpgradeable;
    use starknet::ClassHash;
    use starknet::ContractAddress;

    component!(path: upgradeable_component, storage: upgradeable, event: UpgradeableEvent);

    /// Upgradeable
    impl UpgradeableInternalImpl = upgradeable_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        balance: felt252, 
        #[substorage(v0)]
        upgradeable: upgradeable_component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        UpgradeableEvent: upgradeable_component::Event
    }

    #[external(v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }

    #[external(v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            // Replace the class hash upgrading the contract
            self.upgradeable._upgrade(new_class_hash);
        }
    }

    #[external(v0)]
    #[generate_trait]
    impl HelloStarknetExtImpl of IHelloStarknetExtTrait {

        fn version(self: @ContractState) -> u8 {
            1
        }
    }
}
