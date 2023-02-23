// SPDX-license-Identifier: MIT
pragma solidity ^0.8.10; 

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId); 
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId); 
    event Execute(uint indexed txId); 

    //Structure d'une transaction avec l'adresse qui recoit, la valeur et les données envoyées ainsi que l'état de la transaction
    struct Transaction {
        address to; 
        uint value; 
        bytes data; 
        bool executed; 
    }

    //Tableau d'adresse des propriétaires du MSW 
    address[] public owners; 

    //Definit pour chaque adresse propriétaires un boolean false or true pour confirmer les tractions 
    mapping(address => bool) public isOwner;

    //Est ce que la personne qui modifie les transactions fait parti des owners 
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner"); 
        _; //Executer le reste du code 
    }
    //Nombre de voix pour qu'une transaction soit acceptée, Plus de 50% 
    uint public required; 

    Transcatin[] public transactions; 
    mapping (uint => mapping(address => bool) public approved; 


    //Verifier que l'index de transaction existe pour ne pas creer ou valider une transaction vide ou inexistante
    modifier txExist(uint _txId) {
        require(_txId < transactions.length, "tx doesnt exist");
        _; //Executer le reste du code 
    }

    //Checking le mapping approved pour verifier que cette transcation n'a pas deja etait approuve 
    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }

    //Check que la transaction n'a pas deja ete executer pour eviter les doublons 
    modifier. notExextuted(uint _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }
    //Creation d'une transaction en multi sig 
    constructor(address[] memory _owners, uint _required) {
        //Verification qu'il y est assez de owner et de required 
        require(_owners.length > 0, "owners required"); 
        require(
            _required > 0 && _required <= owners.length,
            "invalid required number of owners"
        );

        //Parcours du tableau pour définir le nombre de owner. 
        for(uint i; i < owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique");

            isOwner[owner] = true; 
            owner.push(owner); 
        }

        required = _required; 
    }

    //Recevoir un montant externe et enregistre la value et l'address 
    receive() external payable{
        emit Deposit(msg.sender, msg.value); 
    }

    //Creer une transaction mise en attente de confirmation par les autres owners 
    function Submit(address _to, uint _value, bytes calldata _data) external onlyOwner {
        transaction.push(Transaction({
            to: _to,
            value: _value, 
            data: _data,
            executed: false
        }));
        emit Submit(transaction.length - 1);
    }

    //validation des autres owners et verification de l'état de la transaction 
    function approve(uint _txId) external onlyOwner txExist(_txId) notApproved(_txId) notExextuted(_txId) {
        approved[_txId][msg.sender] = true; 
        emit Approve(msg.sender, _txId);

    }

    //Verification du nombre dapprove avatn transaction 
    function _getApprovalCount(uint _txId) private view returns (uint count) {
        for(uint i; i < owners.length; i++) {
            if(approved[_txId][owners[i]]) {
                count += 1; 
            }
        }
    }

    // Execution de la transaction 
    function execute( uint _txId) external txExist(_txId) notExextuted(_txId) {
        require(_getApprovalCount(_txId) >= required, "approvas < required"); 
        Transaction storage  transaction = transactions[_txId]; 

        transactions.executed = true; 

        //Bool success est true si la transaction est validée 
        (bool success, )transactions.to.call{value: transaction.value} (
            transaction.data
        );

        //on verifie que la transaction soit validée. Sinon print tx failed 
        require(success, "tx failed"): 

        emit Execute(_txId);
    }

    //Revolve approval by owner 
    function revoke(uint _txId) external onlyOwner txExist(_txId) notExextuted(_txId) {
        //Verifier qu'il ait deja valide la transaction
        require(approved[_txId][msg.sender], "tx not approved"); 
        approved[_txId][msg.sender] = false; 

        emit Revoke(msg.sender, _txId); 
    }
 }
