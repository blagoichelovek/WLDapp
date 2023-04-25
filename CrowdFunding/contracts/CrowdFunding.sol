// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint64 target;
        uint64 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaings;

    uint256 numberOfCompaign = 0;

    function createCampaign(address _owner, string memory _title, string memory _description, uint64 _target, uint64 _deadline, string memory _image) 
    public returns(uint256) {
        Campaign storage campaign = campaings[numberOfCompaign];

        require(campaign.deadline < block.timestamp, "The day of deadline must be in the future");
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline= _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCompaign++;

        return numberOfCompaign;

    }

    function donate(uint256 _id, uint256 _amount) external payable{
        _amount = msg.value;

        Campaign storage campaign = campaings[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(_amount);

        (bool success, ) = payable(campaign.owner).call{value: _amount}("");
        if(success){
            campaign.amountCollected = campaign.amountCollected +  _amount;
        }

    }

    function getDonators(uint256 _id) external view returns(address[] memory, uint256[] memory){
        return(campaings[_id].donators, campaings[_id].donations);
    }

    function getCompaigns() external view returns(Campaign[] memory){
        Campaign[] memory allCampaigns = new Campaign[](numberOfCompaign);

        for(uint i = 0; i < numberOfCompaign; i++){
            Campaign storage item = campaings[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
        
    
}