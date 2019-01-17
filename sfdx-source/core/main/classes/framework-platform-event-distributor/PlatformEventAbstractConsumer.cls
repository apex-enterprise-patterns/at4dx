// Provides default implementation of IEventsConsumer
public abstract class PlatformEventAbstractConsumer implements IEventsConsumer {
    // private, backing properties
    private List<SObject> storedEvents;
    private QueueableContext storedContext;

    // Interface required convenience methods
    public QueueableContext context() { return storedContext; }
    public Boolean isAsynchronous() { return storedContext != null; }
    public List<SObject> events() { return storedEvents; }

    // Constructors
    public PlatformEventAbstractConsumer() {
        storedEvents = new List<SObject>();
    }

    // Interface required public methods
    public void setEvents(List<SObject> events) {
        storedEvents = events;
    }

    // called when consumer is listed as Execute_Synchronous__c == false
    public void execute(QueueableContext context) {
        storedContext = context;
        run();
    }

    // called when consumer is listed as Execute_Synchronous__c == true
    public void run() {
        if (storedEvents == null) { storedEvents = new List<SObject>(); }
        runInProcess();
    }

    // Non-implemented, Interface required public methods
    public abstract void runInProcess();
}
