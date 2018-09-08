public class TestDataSupplementer
{
    private Map<SObjectType, List<ITestDataSupplement>> supplementerMap = null;

    public TestDataSupplementer()
    {
        // for loop using di_Injector.Org.getInstances(...) {

            // populate supplementerMap;

        // }
    }

    public void supplement (List<SObject> sobjectList)
    {
        // iterate through supplementerMap.get(sobjectList.getSObjectType()) {

            // pass sobjectList to the supplementer

        // }
    }
}
