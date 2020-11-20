pragma solidity 0.5.0 ;
pragma experimental ABIEncoderV2;
contract vote {
    
    enum State {proposal, vote , end} //自訂狀態變數
    
    State public  state ;

    uint public endTime ; // 紀錄時間
    address public chairperson; // 主席
    uint id = 0 ; // 提案編號
    
    // 投票紀錄
    struct Voter {
        uint weight; //選票
        bool voted; // 是否投票
        uint voteId; // 提案代碼
    } 
    
    // 紀錄提案票數
    struct Proposal {
        string name ; // 提案名稱
        uint voteCount; // 提案獲得票數
    }
    
    mapping ( address => Voter) public voters ; 
    mapping ( uint => Proposal ) public proposalInfo;

     modifier onlyOwner(){
        require(chairperson == msg.sender , "you are not owner");
        _;
    }
    
    modifier timeEnd(){
        if(now > endTime){
            state = State.end;
        }
        _;
    }

    constructor() public{
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        state = State.proposal;
    }
    function setProposal(string memory _name) public onlyOwner {
        require(state == State.proposal , "state error" );
        proposalInfo[++id] = Proposal(_name , 0);
    }

    function endProposal(uint _limitTime) public onlyOwner returns(State){
        require(state == State.proposal ,"state error");
        state = State.vote;
        endTime = now + _limitTime * 1 minutes ; 
        return state;
    }
    
    function authorization( address _add) public onlyOwner {
        require(voters[_add].voted == false ,"error");
        voters[_add].weight = 1;
    }

    function voteProposal(uint _id) public timeEnd() returns(bool){
        
        if( state == State.vote &&  voters[msg.sender].voted == false){
            voters[msg.sender].voted = true ;
            voters[msg.sender].voteId = _id;
            proposalInfo[_id].voteCount += 1 ;
            return true;
        }
        
        else{
            return false;
        }
        
    }


    function winningProposal() timeEnd() public returns(Proposal memory) {
        require(state == State.end , "state error");
        uint winningVoteCount = 0 ;
        uint winningProposal ;
       
        for(uint i = 1 ; i<=id ; i++ ){
            if(winningVoteCount < proposalInfo[i].voteCount){
                winningVoteCount = proposalInfo[i].voteCount;
                winningProposal = i ;
            }
            
        }
        return proposalInfo[winningProposal];
    }

    
}
