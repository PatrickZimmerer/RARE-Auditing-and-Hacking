# Fallback Ethernaut

- Here no exploit code had to be done since the given code lets you add an arbitrary EoA to the contributions mapping by calling the contribute function with < 0.001 ether so 1 Wei is sufficient, after that do a lowlevel call to the contract with another 1 wei which will call the receive function which requires the sent value > 0 and the address to be in the contributions mapping and then sets the msg.sender as owner which will give you control over the contract and you can now drain the contract.
