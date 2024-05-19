import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract lending_protocol{
    IERC20 public immutable token;
    // mapping(address => mapping(address => 
    // (uint256 amount, uint rate, uint256 collateral, uint duration))) public lenders;
    // mapping(address => mapping(address => uint256)) public borrowers;
   mapping(address => uint256)) public lenders;
   mapping(address => uint256)) public borrowers;

   mapping(address => mapping(address => uint256)) public all_lenders;
   mapping(address => mapping(address => uint256)) public all_borrowers;
    // function condition_lending(uint256 amount, uint rate, uint256 collateral, uint duration) external {
    //     lendings[msg.sender] = (amount, rate, collateral, duration);
    //             //condition_lending(amount, rate, collateral, duration);
    // }
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

נניח את הנתונים הבאים:

total borrowed (סה"כ הושאל) = 50,000 DAI
total deposited (סה"כ הופקד) = 100,000 DAI
interest multiplier = 0.05 (5%)
base rate = 0.02 (2%)
חישוב יחס ניצול:
utilization ratio
=
50
,
000
100
,
000
=
0.5
utilization ratio= 
100,000
50,000
​
 =0.5

חישוב borrowRate:
borrowRate
=
(
0.5
×
0.05
)
+
0.02
borrowRate=(0.5×0.05)+0.02
borrowRate
=
0.025
+
0.02
borrowRate=0.025+0.02
borrowRate
=
0.045
borrowRate=0.045

לכן, שיעור הריבית השנתי הוא 4.5%.

חישוב העמלה:
נניח סכום ההלוואה (_amount) הוא 1,000 DAI.
fee
=
1
,
000
×
0.045
=
45
 DAI לשנה
fee=1,000×0.045=45 DAI לשנה



Utilization ratio גבוה (נניח 80%):
utilization ratio
=
0.8
utilization ratio=0.8
borrowRate
=
(
0.8
×
0.05
)
+
0.02
borrowRate=(0.8×0.05)+0.02
borrowRate
=
0.04
+
0.02
borrowRate=0.04+0.02
borrowRate
=
0.06
borrowRate=0.06 (כלומר 6% לשנה)