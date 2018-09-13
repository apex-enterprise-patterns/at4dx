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
}
