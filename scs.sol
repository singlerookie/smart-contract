pragma solidity ^0.4.17;
contract project{
    uint internal idnumber = 0;
    uint internal transactionid = 0;
    
    struct user {
        string name; 
        uint id; 
        int plan; 
        int plancopy;
        int pastplan;
        int pastpastplan;
        int currentvolume;
        int reallyamount;
        int price; 
        int balance; 
        uint powertype; 
        uint[] transactionidsgroup;
        int creditpiont;
       
    }
    
    struct transationpool{
    	uint[] customersid;
    	string customersname;
    	uint[] producersid;
    	string producersname;
    	uint transactionid;
    	int transactionprize;
    	int transactionamount;
    }

    transationpool[] public transationmassagegroup;
    uint[] public producersidgroup; 
    uint[] public customersidgroup; 
    mapping(address => user) users;
    mapping(uint => user)IdToUser;
    mapping(uint => transationpool)transationmassage;
    uint[] useridgroup;

    function Register(string  _name) public returns(string,uint){
		uint _id;
		idnumber++;
		_id = idnumber;
		users[msg.sender].id = _id;
		users[msg.sender].name = _name;
		IdToUser[users[msg.sender].id] = users[msg.sender];
		IdToUser[_id].creditpiont = 100;

		useridgroup.push(users[msg.sender].id);
        return("注册成功",users[msg.sender].id);
		
	}
	function creditpointpunish(uint _id,int _punish) external  returns(int){
	    IdToUser[_id].creditpiont = IdToUser[_id].creditpiont - _punish;
	    return IdToUser[_id].creditpiont;
	}


	function Initialize()internal{
	    delete users[msg.sender].price;
	    delete users[msg.sender].plan;
	    delete users[msg.sender].powertype;
	}
	function BidBeforeTransation(int _price, int _plan,uint _type,uint _id,int _currentvolume) public returns(string){//规定_type 0表示买方，1表示卖方
		IdToUser[_id].plan= _plan;
		IdToUser[_id].plancopy= _plan;
		IdToUser[_id].price = _price;
		IdToUser[_id].powertype = _type;
		IdToUser[_id].currentvolume = _currentvolume;
		if(IdToUser[_id].plan > 0 && _type == 0){
				customersidgroup.push(users[msg.sender].id);
				return("买方申报成功，请继续。");
		}
		
		else if(IdToUser[_id].plan > 0 && _type ==1){
				producersidgroup.push(users[msg.sender].id);
				return("卖方申报成功，请继续。");
		}
		
		else return("申报量不能为0，请重试。");
	}
	function ArrangePriceFromHighToLow()internal{
		if( customersidgroup.length != 0){
			uint t;
			for(uint i = 0;i < (customersidgroup.length -1);i++){
				for(uint j = 0;j < (customersidgroup.length-i-1);j++){
					if (IdToUser[customersidgroup[j]].price * IdToUser[customersidgroup[j]].creditpiont <= IdToUser[customersidgroup[j+1]].price * IdToUser[customersidgroup[j+1]].creditpiont){//后一位比前一位大，利用中间量t换位
						t = customersidgroup[j+1];
						customersidgroup[j+1] = customersidgroup[j];
						customersidgroup[j] = t;
					}
					
				}
			}

		}
	}
	function ArrangePriceFromLowToHigh()internal{
		if(producersidgroup.length != 0){
			uint t;
			for(uint i = 0;i <(producersidgroup.length-1);i++){
				for(uint j = 0;j<(producersidgroup.length-i-1);j++){
					if( IdToUser[producersidgroup[j]].price *(100 - IdToUser[producersidgroup[j]].creditpiont) >= IdToUser[producersidgroup[j+1]].price*(100 - IdToUser[producersidgroup[j]].creditpiont)) {
						t = producersidgroup[j+1];
						producersidgroup[j+1] = producersidgroup[j];
						producersidgroup[j] = t;


					}
				}
			}
		}

	}
	function GetCustomerBidprice()external view returns(int[]){
		int[] memory result = new int[](customersidgroup.length);
		uint counter = 0;
		for(uint i=0;i<customersidgroup.length;i++){
				result[counter] = IdToUser[customersidgroup[i]].price;
				counter++;
			}
			return result;
		}
	function GetCustomerBidplan()external view returns(int[]){
		int[] memory result = new int[](customersidgroup.length);
		uint counter = 0;
		for(uint i=0;i<customersidgroup.length;i++){
				result[counter] = IdToUser[customersidgroup[i]].plan;
				counter++;
			}
			return result;
		}

	function GetproducerBidprice()external view returns(int[]){
		int[] memory result = new int[](producersidgroup.length);
		uint counter = 0;
		for(uint i=0;i<producersidgroup.length;i++){
				result[counter] = IdToUser[producersidgroup[i]].price;
				counter++;
			}
			return result;
		}
	function GetproducerBidplan()external view returns(int[]){
		int[] memory result = new int[](producersidgroup.length);
		uint counter = 0;
		for(uint i=0;i<producersidgroup.length;i++){
				result[counter] = IdToUser[producersidgroup[i]].plan;
				counter++;
			}
			return result;
		}
	function DoubleSideAuction() public {
		ArrangePriceFromLowToHigh();
		ArrangePriceFromHighToLow();
		int pricex;
		int amounty;
		for(uint i = 0;i < (producersidgroup.length);i++){
			for(uint j = 0;j < (customersidgroup.length);j++){
				if(IdToUser[producersidgroup[i]].price <= IdToUser[customersidgroup[j]].price){
					if(IdToUser[producersidgroup[i]].plan<=IdToUser[customersidgroup[j]].plan){
						amounty = IdToUser[producersidgroup[i]].plan;
						if(IdToUser[producersidgroup[i]].creditpiont > IdToUser[customersidgroup[j]].creditpiont){
							pricex = (IdToUser[producersidgroup[i]].price + (IdToUser[customersidgroup[j]].price) - IdToUser[producersidgroup[i]].price) * IdToUser[producersidgroup[i]].creditpiont/(IdToUser[producersidgroup[i]].creditpiont + IdToUser[customersidgroup[j]].creditpiont);
						}
						else{
							pricex = (IdToUser[producersidgroup[i]].price + (IdToUser[customersidgroup[j]].price) - IdToUser[producersidgroup[i]].price) * IdToUser[customersidgroup[j]].creditpiont/(IdToUser[producersidgroup[i]].creditpiont + IdToUser[customersidgroup[j]].creditpiont);
						}
						
					}
					else {
					    amounty = IdToUser[customersidgroup[j]].plan;
						if(IdToUser[producersidgroup[i]].creditpiont > IdToUser[customersidgroup[j]].creditpiont){
							pricex = (IdToUser[producersidgroup[i]].price + (IdToUser[customersidgroup[j]].price) - IdToUser[producersidgroup[i]].price) * IdToUser[producersidgroup[i]].creditpiont/(IdToUser[producersidgroup[i]].creditpiont + IdToUser[customersidgroup[j]].creditpiont);
						}
						else{
							pricex = (IdToUser[producersidgroup[i]].price + (IdToUser[customersidgroup[j]].price) - IdToUser[producersidgroup[i]].price) * IdToUser[customersidgroup[j]].creditpiont/(IdToUser[producersidgroup[i]].creditpiont + IdToUser[customersidgroup[j]].creditpiont);
						}
						
				
					}
					if(amounty !=0)transaction(producersidgroup[i],customersidgroup[j],amounty,pricex);
				}
				
			}
		}

	}
	function AuctionFinish()internal{
		for(uint i = 0;i < (producersidgroup.length);i++){
			if(IdToUser[producersidgroup[i]].plan == 0){
			delete producersidgroup[i];	
			}
		}
		for(uint j = 0;j < (customersidgroup.length);j++){
			if(IdToUser[customersidgroup[j]].plan == 0){
				delete customersidgroup[j];
			}
		}
	}
	function transaction(uint _produceid,uint _customerid,int _amount,int _price)internal{
		transactionid = transactionid + 1;
		IdToUser[_produceid].plan = IdToUser[_produceid].plan - _amount;
		IdToUser[_produceid].balance = IdToUser[_produceid].balance + _amount * _price;
		IdToUser[_produceid].pastplan =IdToUser[_produceid].pastplan +_amount;
		IdToUser[_customerid].plan = IdToUser[_customerid].plan - _amount;
		IdToUser[_customerid].balance = IdToUser[_customerid].balance - _amount * _price;
		IdToUser[_customerid].pastplan =IdToUser[_customerid].pastplan +_amount;
		transationmassage[transactionid].customersid.push(_customerid);
		transationmassage[transactionid].customersname = IdToUser[_customerid].name;
		transationmassage[transactionid].producersid.push(_produceid);
		transationmassage[transactionid].producersname = IdToUser[_produceid].name;
		transationmassage[transactionid].transactionamount = _amount;
		transationmassage[transactionid].transactionprize = _price;
		transationmassagegroup.push(transationmassage[transactionid]);
	}


	function DeleteOrder(uint _id)public returns(string){
		Initialize();
		return("您已退出交易。");
	}
	function getbalance(uint _id)public view returns(int){
		return IdToUser[_id].balance;
	}
	function setbalance(uint _id ,int _balance) public returns(string){
		IdToUser[_id].balance = IdToUser[_id].balance + _balance;
		return("充值成功");
	}

	function getdoneplan(uint _id) view returns(int){
	    return IdToUser[_id].pastplan;
	}
	
	function getyourcreditpoint(uint _id)returns(int){
	    return IdToUser[_id].creditpiont;
	}


	



    
}



