public with sharing class TestDataFactory {
    
    public static List<Account> getAccList(Integer numAccts){
        List<Account> acctList = new List<Account>(); 
        for(Integer i=0; i<numAccts; i++){
    	    acctList.add(new Account(Name='TestAccount'+i));
        }
        return acctList;
    }
    
    public static Account getSingleAccount(){
        Account singleAccount = 
            new Account(Name='NewTestAccount1');
        return singleAccount;
    }
}
