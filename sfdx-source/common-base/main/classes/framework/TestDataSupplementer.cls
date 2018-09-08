public class TestDataSupplementer
{
    private Map<SObjectType, List<ITestDataSupplement>> supplementerMap = new Map<SObjectType, List<ITestDataSupplement>>();

    public TestDataSupplementer()
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

            if (sobjType == null)
            {
                System.debug(
                    LoggingLevel.ERROR,
                    'SObjectType, ' + tds_mdt.BindingSObjectType__c + 
                    ', specified in  ' + tds_mdt.DeveloperName + 
                    ' does not exist.'
                );

                continue;
            }

            ITestDataSupplement instance = null;
            if (String.isNotBlank(tds_mdt.SupplementingClass__c))
            {
                Type t = Type.forName(tds_mdt.SupplementingClass__c);

                if (t == null)
                {
                    System.debug(
                        LoggingLevel.ERROR,
                        'Type , ' + tds_mdt.SupplementingClass__c + 
                        ', specified in  ' + tds_mdt.DeveloperName + 
                        ' does not exist.');

                    continue;
                }

                instance = (ITestDataSupplement) t.newInstance();
            }

            if (instance == null)
            {
                System.debug(
                    LoggingLevel.ERROR,
                    'Type , ' + tds_mdt.SupplementingClass__c + 
                    ', specified in  ' + tds_mdt.DeveloperName + 
                    ' could not be created.');

                continue;
            }

            if (!supplementerMap.containsKey(sobjType))
            {
                supplementerMap.put(sobjType, new List<ITestDataSupplement>());
            }

            supplementerMap.get(sobjType).add(instance);

        }

        System.debug(supplementerMap);
    }

    public void supplement (List<SObject> sobjectList)
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
