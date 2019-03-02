/**
 * Copyright (c) 2018, John M. Daniel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the John M. Daniel, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/*********************************************************************
 * @description  Interface for the EventsConsumer used by PlatformEventDistributor to inject dynamic subscribers to Platform Events
**/ 
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
