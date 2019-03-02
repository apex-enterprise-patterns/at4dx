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
 * @description  Default implementation of IEventsConsumer. 
 *               runInProcess() must be given a body by the implementing class.
**/ 
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