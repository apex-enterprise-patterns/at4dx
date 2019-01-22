/*********************************************************************
* @author Rick Parker
* @date 2019-01-22
*
* @description  Default implementation of IEventsConsumer. 
*               runInProcess() must be given a body by the implementing class.
*
* AUTHOR         DATE        DETAIL
* Rick Parker    2019-01-22  Created
**********************************************************************/ 
public abstract class PlatformEventAbstractConsumer implements IEventsConsumer {
    /*******************************************************************************************************
    * @description List of events to be processed
    * @return List<SObject>
    *******************************************************************************************************/
    protected List<SObject> events = new List<SObject>();

    /*******************************************************************************************************
    * @description The QueueableContext to be executed under, if queued
    * @return QueueableContext
    *******************************************************************************************************/
    protected QueueableContext context;

    /*******************************************************************************************************
    * @description Whether the Events Consumer is being processed Synchronously, in the same process
    * @return Boolean
    *******************************************************************************************************/
    protected Boolean isSynchronous = false;

    /*******************************************************************************************************
    * @description Sets the events used when processing
    * @return IEventsConsumer, to allow chaining
    *******************************************************************************************************/
    public IEventsConsumer setEvents(List<SObject> events) {
        this.events = events;
        return this;
    }

    /*******************************************************************************************************
    * @description Sets the processing to Synchronous
    * @return IEventsConsumer, to allow chaining
    *******************************************************************************************************/
    public IEventsConsumer setRunSynchronous() {
        isSynchronous = true;
        return this;
    }

    /*******************************************************************************************************
    * @description Called when the Events Consumer is spawned as a Queueable
    * @return void
    *******************************************************************************************************/
    public void execute(QueueableContext context) {
        try
        {
            this.context = context;
            runInProcess();
        }
        catch (Exception e)
        {
            system.debug(e);
            system.debug(e.getStackTraceString());
        }
    }

    /*******************************************************************************************************
    * @description Called by the PlatformEventDistributor to spawn either a Queueable or to run in process
    * @return Id of the queued job, if queued
    *******************************************************************************************************/
    public Id run() {
        if (events == null || events.isEmpty()) { return null; }
        if (isSynchronous) {
            runInProcess();
            return null;
        }
        else {
            return System.enqueueJob( this );
        }
    }

    /*******************************************************************************************************
    * @description Execution method where the real work is accomplished. Called by either run() or execute(context)
    * @return void
    *******************************************************************************************************/
    public abstract void runInProcess();
}