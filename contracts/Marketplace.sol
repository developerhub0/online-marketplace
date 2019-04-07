pragma solidity ^0.5.2;

import 'node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';
import './StoreOwner.sol';

contract Marketplace is Ownable {
    address[] private adminsArr;
    mapping (address => bool) private admins;

    address[] private storeOwnersAddr;
    mapping (address => bool) private storeOwnersActive;
    mapping (address => StoreOwner) private storeOwners;
    
    modifier onlyAdmin() {
        require(isAdmin());
        _;
    }
    
    modifier onlyStoreOwner() {
        require(isStoreOwner());
        _;
    }
    
    function addAdmin(address adminAddr) public payable onlyOwner {
        if(admins[adminAddr] == false) {
            admins[adminAddr] = true;
            adminsArr.push(adminAddr);
        } else {
            revert("This address is admin already!");
        }
    }

    function getAdmins() public view onlyOwner returns(address[] memory) {
        return adminsArr;
    }

    function isAdmin() public view returns (bool) {
        return admins[msg.sender] == true;
    }
    
    function addStoreOwner(address storeOwnerAddr) public onlyAdmin {
        if(storeOwnersActive[storeOwnerAddr] == true){
            revert("This address is store owner already!");
        }    

        storeOwnersActive[storeOwnerAddr] = true;
        storeOwnersAddr.push(storeOwnerAddr);
        storeOwners[storeOwnerAddr] = new StoreOwner();
        storeOwners[storeOwnerAddr].setAddress(storeOwnerAddr);
    }
    
    function getStoreOwners() public view onlyAdmin returns(address[] memory) {
        return storeOwnersAddr;
    }

    function isStoreOwner() public view returns(bool) {
        return storeOwnersActive[msg.sender] == true;
    }
    
    function addStoreFront(string memory storeName) public payable onlyStoreOwner {
        if(storeOwnersActive[msg.sender] == true) {
            StoreFront storeFront = new StoreFront();
            storeFront.setName(storeName);
            storeOwners[msg.sender].addStoreFront(storeFront);
        }
    }

    function getStoreFrontName(uint index) public view onlyStoreOwner returns (string memory) {
        return storeOwners[msg.sender].getStoreFronts()[index].getName();
    }
    
    function getStoreFronts() public view onlyStoreOwner returns(StoreFront[] memory) {
        return storeOwners[msg.sender].getStoreFronts();
    }
    
    function addProduct(
        uint storeFrontId,
        string memory title, 
        string memory description, 
        uint price
    ) public payable onlyStoreOwner {
        require(abi.encodePacked(title).length > 0, "Product title is required!");
        require(price > 0, "Price is required!");
        
        StoreFront[] memory storeFronts;
        storeFronts = getStoreFronts();
        
        validate(storeFronts.length, storeFrontId, "Store front doesn't exist for this shop owner!");
                
        return storeOwners[msg.sender].getStoreFront(storeFrontId).addProduct(title, description, price);
    }

    function removeProduct(uint storeFrontId, uint productId) public payable onlyStoreOwner {
        StoreFront[] memory storeFronts;
        storeFronts = getStoreFronts();
        
        validate(storeFronts.length, storeFrontId, "Store front doesn't exist for this shop owner!");

        storeOwners[msg.sender].getStoreFront(storeFrontId).removeProduct(productId);
    }
    
    // function getProduct(uint storeFrontId, uint productId) public view onlyStoreOwner returns (string memory, string memory, uint) {
    //     StoreFront[] memory storeFronts;
    //     storeFronts = getStoreFronts();
        
    //     validate(storeFronts.length, storeFrontId, "Store front doesn't exist for this shop owner!");
        
    //     for(uint i = 0; i < storeFronts.length; i++) {
    //         validate(storeFronts[i].getProductsLength(), productId, "Product doesn't exist for this shop owner's store front!");
            
    //         if(i == storeFrontId) {
    //             return storeFronts[i].getProduct(productId);    
    //         }
    //     }
    // }

    function getProductsLength(uint storeFrontIndex) public view returns(uint) {
        StoreFront[] memory storeFronts;
        storeFronts = getStoreFronts();
        return storeFronts[storeFrontIndex].getProductsLength();
    }

    function getProduct(uint storeFrontIndex, uint productIndex) public view onlyStoreOwner returns(string memory, string memory, uint) {
        StoreFront[] memory storeFronts;
        storeFronts = getStoreFronts();
        
        validate(storeFronts.length, storeFrontIndex, "Store front doesn't exist for this shop owner!");
        validate(storeFronts[storeFrontIndex].getProductsLength(), productIndex, "Product doesn't exist for this shop owner's store front!");

        return storeOwners[msg.sender].getStoreFronts()[storeFrontIndex].getProduct(productIndex);
    }
    
    function validate(uint itemsLength, uint index, string memory message) private view onlyStoreOwner {
        if(itemsLength - 1 < index || itemsLength == 0) {
            revert(message);    
        }   
    }
}