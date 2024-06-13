// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";
import "../MyTokens/my_bond_token.sol;
// import "@openzeppelin/ERC20/extensions/ERC20Permit.sol";

contract lending_protocol{
    IERC20 public immutable daiToken;

    mapping(address => uint256) public collateralValue;
    mapping(address => uint256) public borrowedValue;
    mapping(address => uint256) public depositedValue;
    mapping(address => uint256) public earnedInterestValue;
    mapping(address => uint256) public lastUpdate;
    mapping(address => uint256) public lastUpdate;
    
    uint256 public totalBorrowed;
    uint256 public totalDeposit;
    uint256 public totalCollateral;
    uint public borrowRate;
    uint public baseRate;
    uint public utilizationRatio;//שיעור הניצול
    uint public interestMultiplier;//שיעור הריבית המוכפלת בניצול
    
    MyBondToken public bond;

    event eventBorrowLimit(address indexed borrower, string message);

    receive() external payable {}

    constractor(uint baseRate, uint interestMultiplier, uint maxLTV){
        daiToken = IERC20(0x6b175474e89094c44da98b954eedeac495271d0f);
        bondToken = new MyBondToken(); 
        this.baseRate = baseRate;
        this.interestMultiplier = interestMultiplier;
        this.maxLTV = maxLTV;
    }
    function deposit(uint256 amountDAI) external {
        this.calEarnedInterest();//!! call it just after , there is a deposit surly,but before the deposit, because i change ther the lastUpdate to current date
        daiToken.transfer(address(this), amountDAI)
        totalDeposit += amountDAI;
        depositedValue[msg.sender] += amountDAI;
        //get him bond tokens 
        bondToken.mint(msg.sender, amount);
    }    
    function calEarnedInterest() internal {
        if(lastUpdate[msg.sender] != 0){
            uint256 numDays = (block.timestamp - lastUpdate[msg.sender]) / 1 days;//(endDate - startDate) / 1 days;
            uint depositRate;//שיעור הריבית שהמפקיד מרוויח
            depositRate = calUtilizationRatio() * calBorrowRate() * numDays * depositedValue[msg.sender];//?? זה נכון או לחשב את זה בצורה כזאת עם פונקציות //depositRate = utilizationRatio * borrowRate
            //depositRate = calUtilizationRatio() * calBorrowRate() חשב את שיעור ההפקדה:
            earnedInterestValue[msg.sender] += depositRate;

            lastUpdate[msg.sender] = block.timestamp;//update to the current date
        }
    }
    function calBorrowRate() internal returns(uint){//חשב שיעור הלוואה:
        borrowRate = baseRate + (calUtilizationRatio() * interestMultiplier);//?? אבל כל שניה יחס הניצול משתנה מה לעשות
        return borrowRate;
    }
    function calUtilizationRatio()internal returns(uint) {//חשב את יחס ניצול:
        utilizationRatio = getExp(totalBorrowed, totalDeposit);//give the ratiobetween both, getExp: 1.exactly, 2.readable code-we will know code's designation
        return utilizationRatio;
    }
    function unbond_bond_tokens(uint256 amountDAI) external {
        this.calEarnedInterest();//!! call it just after ,
        daiToken.transferFrom(address(this), msg.sender, amountDAI)
        totalDeposit -= amountDAI;
        depositedValue[msg.sender] -= amountDAI;
        //take him bond tokens 
        bondToken.burn(msg.sender, amount);
    }
    function add_collateral() external payable {
        payable(address(this)).transfer(msg.value);
        totalCollateral += msg.value;
        collateralValue[msg.sender] += amountEth;

        emit eventBorrowLimit(msg.sender, "you can borrow " + borrowLimit() + " DAI.");
    } 
    function borrowLimit(address borrower) {//חשב את מגבלת ההשאלה: 
        // להמיר לאתר או לדהיי
        return percentage((collateralValue[borrower] - borrowedValue[borrower]), maxLTV);
    }
    function borrow(uint256 amountDAI) external {
        require(borrowLimit() >= amountDAI, "you cant borrow");
        daiToken.transferFrom(address(this), msg.sender, amountDAI);
        totalBorrowed += totalBorrowed;
        borrowedValue[msg.sender] += amountDAI;
    }
    function remove_collateral() external payable {
        //need to check that he didnt take borrow ,else he cant take it ?
        //token.transferFrom(address(this), msg.sender, amountEth)
        payable(msg.sender).transfer(msg.value);
        totalCollateral -= msg.value;
        collateralValue[msg.sender] -= msg.value;
        liquidationThreshold = percentage(collateralValue, maxLTV)//?? total?
    } 
    function repay_debt(uint256 amountDAI) external {

    }







 borrowLimit = percentage((collateralValue - borrowedValue), maxLTV)
fee = _amount * borrowRate
liquidationThreshold = percentage(collateralValue, maxLTV)
exchangeRate = getExp((cash + totalBorrowed + totalReserve), totalSupply())
utilizationRatio = getExp(totalBorrowed, totalDeposit)
borrowRate = (utilizationRatio * interestMultiplier) + baseRate
depositRate = utilizationRatio * borrowRate


















//?? review()    payable , to understand why precent of eth in remove collateral is in msg.value

// public internal external.......
    function deposit(uint256 amountDAI, uint rate, uint256 collateral, uint duration) external {
        require(amountDAI > 0, "is 0");
        require(token.balanceOf(msg.sender) >= amountDAI, "not enough");
        token.transfer(address(this), amountDAI)
        //transfer bond tokens ??

        //save the details
        lenders[msg.sender] += amountDAI;    
    }
    function unbond_bond_tokens(uint256 amountDAI) external {
        require(amountDAI > 0, "is 0");
        require(lenders[msg.sender] >= amountDAI, "not enough");//ensure his money not by borrower??
        //transfer : take back bond tokens ??
        token.transferFrom(address(this), msg.sender, amountDAI)
        lenders[msg.sender] -= amountDAI;    
    }
    function add_collateral(uint256 amountEth) external {//??token fo eth and dai
        require(amountEth > 0, "is 0");
        require(token.balanceOf(msg.sender) >= amountEth, "not enough");
        token.transfer(address(this), amountEth);
        borrowers[msg.sender] += amountEth;
    }   
    function remove_collateral(uint256 amountEth) external {
        require(amountEth > 0, "is 0");
        require(borrowers[msg.sender] >= amountEth, "not enough");
        //?? need  to check that he didnt take borrow ,else he cant take it
        borrowers[msg.sender] -= amountEth;
    } 
    function borrow(uint256 amountDAI) external {
        require(amountEth > 0, "is 0");
        all_borrowers[msg.sender][address(0)] = amountDAI;//if will be more , it a prob..neded identity instead
    }
    function repay_debt(uint256 amountDAI, address lender) external {
        require(amountDAI > 0, "is 0");
        require(token.balanceOf(msg.sender) >= amountDAI, "not enough");
        require(all_borrowers[msg.sender][lender] >= amountDAI, "no lending for the lender");//data base check ?? how storage
        //?? all_borrowers[msg.sender][lender]  not exist so can i ask the ques..>= amountDAI, or it error above not exists something 
        token.transfer(lender, amountDAI);

        //save it
        all_borrowers[msg.sender][lender] -= amountDAI;
        //?? לסדר גם שכשעושים תשורה הקודמת זה לא ישבש כמה הללואות מאותו לווה
        if(all_borrowers[msg.sender][lender] == 0)
        //return the rollateral or function he take it alone- i did, check the combine...
    }
}