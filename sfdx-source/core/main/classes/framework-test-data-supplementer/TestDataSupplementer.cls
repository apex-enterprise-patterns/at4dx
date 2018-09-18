@IsTest
public class TestDataSupplementer
{
    private static Map<SObjectType, List<ITestDataSupplement>> supplementerMap = new Map<SObjectType, List<ITestDataSupplement>>();

    static
    {
        for (
            di_Binding binding
            :
            di_Injector.Org.Bindings
                .byName(ITestDataSupplement.class.getName())
                .get()
        )
        {
            TestDataSupplementer__mdt tds_mdt = (TestDataSupplementer__mdt) binding.Data;
            SObjectType sobjType = Schema.getGlobalDescribe().get(tds_mdt.BindingSObjectType__c);

            if (!supplementerMap.containsKey(sobjType))
            {
                supplementerMap.put(sobjType, new List<ITestDataSupplement>());
            }

            supplementerMap.get(sobjType).add((ITestDataSupplement) binding.getInstance());
        }
    }

    public static void supplement (List<SObject> sobjectList)
    {
        if (sobjectList != null && !sobjectList.isEmpty())
        {
            for (ITestDataSupplement supplementer : supplementerMap.get(sobjectList.getSObjectType()))
            {
                supplementer.supplement(sobjectList);
            }
        }
    }
}
