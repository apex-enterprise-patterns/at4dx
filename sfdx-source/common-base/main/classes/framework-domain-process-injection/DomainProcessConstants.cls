public class DomainProcessConstants 
{
    private DomainProcessConstants() { }

    public enum PROCESS_CONTEXT
    {
        DomainMethodExecution,
        TriggerExecution
    }

    public enum PROCESS_TYPE
    {
        CRITERIA,
        ACTION
    }

//    public enum TRIGGER_OPERATION_TYPE
//    {
//        AfterInsert,
//        BeforeInsert,
//        AfterUpdate,
//        BeforeUpdate,
//        AfterDelete,
//        BeforeDelete,
//        AfterUndelete
//    } 
}