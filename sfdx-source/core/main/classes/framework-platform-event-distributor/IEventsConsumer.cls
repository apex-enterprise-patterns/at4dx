/*********************************************************************
* @author John Daniel, Rick Parker
* @date 2019-01-22
*
* @description  Interface for the EventsConsumer used by PlatformEventDistributor to inject dynamic subscribers
*               to Platform Events
*
* AUTHOR         DATE        DETAIL
* John Daniel    ????-??-??  Created
* Rick Parker    2019-01-22  Updated to add Synchronous processing capabilities
**********************************************************************/ 
public interface IEventsConsumer extends Queueable {
    /*******************************************************************************************************
    * @description Adds events to the Events Consumer for use during execution
    * @return An instantiation of IEventsConsumer, for chaining
    *******************************************************************************************************/
    IEventsConsumer setEvents(List<SObject> events);

    /*******************************************************************************************************
    * @description  Sets the Events Consumer to run synchronously. By default, the Events Consumer will run as a Queueable.
    *               Executing this method causes the Events Consumer to run in the same process without being queued. 
    * @return An instantiation of IEventsConsumer, for chaining
    *******************************************************************************************************/
    IEventsConsumer setRunSynchronous();


    /*******************************************************************************************************
    * @description  This method is called by PlatformEventDistributor and is expected to either System.enqueueJob or run in process
    *               appropriately, based upon usage of setRunSynchronous() 
    * @return  The Id of the job being enqueued, or null if running in process
    *******************************************************************************************************/
    Id run();
}
