// All subscribers to the Platform Event Distributor process should be implementations of this interface
// It is highly recommended, for ease of use and adoption, for implementing classes to instead implement the abstract class
//      named PlatformEventAbstractConsumer as it implements most of the contents of this interface on your behalf,
//      leaving only runInProcess to be implemented by an end-line a developer
public interface IEventsConsumer extends Queueable {
    // The following methods are to be used alongside backing properties for each value
    // context() should return the QueueableContext identified by execution of the .execute(QueueableContext) method required by Queueable
    QueueableContext context();
    // isAsynchronous() is a convenience method that should return true if .execute(QueuealeContext) was called, and otherwise should return false
    Boolean isAsynchronous();
    // events() should return the events list passed in via the setEvents(List<SObject>) method
    List<SObject> events();

    // This method is called by PlatformEventDistributor to inject event details into the process
    // This method is implemented in PlatformEventAbstractConsumer
    void setEvents(List<SObject> events);

    // This method is called internally by .execute(QueueableContext) and .run() methods, and is NOT called by PlatformEventDistributor
    // This method is defined as ABSTRACT in PlatformEventAbstractConsumer, and is the only method that must be implemented when using that class as a base
    void runInProcess();

    // This method is called by PlatformEventDistributor when the subscription is set to 'Execute Synchronous'
    // This method is implemented in PlatformEventAbstractConsumer, and calls down to runInProcess() without expectation of being inside of a Queueable
    void run();
}
