pragma solidity ^0.8.0;

contract InsuranceContract {
    uint public coverageAmount;
    uint public premiumAmount;
    uint public duration;
    mapping(address => uint) public premiumsPaid;
    mapping(address => bool) public isInsured;

    constructor(uint _coverageAmount, uint _premiumAmount, uint _duration) {
        coverageAmount = _coverageAmount;
        premiumAmount = _premiumAmount;
        duration = _duration;
    }

    function register() public {
        require(!isInsured[msg.sender], "You are already insured");
        isInsured[msg.sender] = true;
    }

    function payPremium() public payable {
        require(isInsured[msg.sender], "You are not insured");
        require(msg.value == premiumAmount, "Incorrect amount sent");
        premiumsPaid[msg.sender] += msg.value;
    }

    function makeClaim() public {
        require(isInsured[msg.sender], "You are not insured");
        require(block.timestamp <= duration, "The policy has expired");

        // Add your own conditions for automatic payouts here
        if (msg.sender.balance <= 1 ether) {
            payable(msg.sender).transfer(coverageAmount);
        } else {
            // If conditions not met, require manual processing of the claim
            require(address(this).balance >= coverageAmount, "Insufficient funds in the contract");
        }
    }

    function cancelPolicy() public {
        require(isInsured[msg.sender], "You are not insured");
        require(premiumsPaid[msg.sender] > 0, "No premiums have been paid");
        uint refundAmount = premiumsPaid[msg.sender];
        premiumsPaid[msg.sender] = 0;
        isInsured[msg.sender] = false;
        payable(msg.sender).transfer(refundAmount);
    }

    function updatePolicy(uint _coverageAmount, uint _premiumAmount, uint _duration) public {
        require(isInsured[msg.sender], "You are not insured");
        require(premiumsPaid[msg.sender] >= premiumAmount, "Premiums are not up to date");
        coverageAmount = _coverageAmount;
        premiumAmount = _premiumAmount;
        duration=_duration;
    }

    function highRiskClaim() public {
        require(isInsured[msg.sender], "You are not insured");
        require(block.timestamp <= duration, "The policy has expired");
        require(address(this).balance >= coverageAmount, "Insufficient funds in the contract");
        

        // Increase the chance of the claim being processed by generating a random number
        // If the number is even, process the claim automatically
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10;
        if (rand % 2 == 0) {
            payable(msg.sender).transfer(coverageAmount);
        } else {
            // If the number is odd, the claim must be manually processed
            revert("High-risk claim requires manual processing");
        }
    }
}

contract MyContract {
    InsuranceContract public insuranceContract;

    constructor() {
        // Create a new insurance contract with coverage amount of 1 ether, premium amount of 0.1 ether, and duration of 30 days
        insuranceContract = new InsuranceContract(1 ether, 0.1 ether, 30 days);
    }

    function registerForInsurance() public {
        // Register for insurance by calling the register function in the insurance contract
        insuranceContract.register();
    }

    function payInsurancePremium() public payable {
        // Pay the insurance premium by calling the payPremium function in the insurance contract with the premium amount as the value
        insuranceContract.payPremium{value: msg.value}();
    }
    //function makeInsuranceClaim()
}