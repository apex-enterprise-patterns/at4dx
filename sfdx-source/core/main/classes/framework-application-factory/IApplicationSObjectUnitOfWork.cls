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

/**
 *  IApplicationSObjectUnitOfWork
 */
public interface IApplicationSObjectUnitOfWork
    extends fflib_ISObjectUnitOfWork
{
    list<SObject> getNewRecordsByType( Schema.SObjectType typeToFind );
    Map<Id, SObject> getDirtyRecordsByType( Schema.SObjectType typeToFind );
    Map<Id, SObject> getDeletedRecordsByType( Schema.SObjectType typeToFind );

    /**
     * Register a SObject instance to be either inserted or updated when commitWork is called
     *
     * @param record A SObject instance to be inserted or updated during commitWork
     **/
    void register(SObject record);

    /**
     * Register a list of SObject instances to be either inserted or updated when commitWork is called
     *
     * @param records A list SObject instances to be either inserted or updated during commitWork
     **/
    void register(List<SObject> records);

    void register(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord);

    /**
     * Registers a group of emails to be sent during the commitWork
     **/
    void registerEmails( list<Messaging.Email> emails );


    /**
     * Register platform events to be emitted prior to the beginning of the data base transaction
     */
    void registerPublishBeforeTransaction( List<SObject> events );

    /**
     * Register platform events to be emitted after the conclusion of the data base transaction if it is successful
     */
    void registerPublishAfterTransactionSuccess( List<SObject> events );

    /**
     * Register platform events to be emitted after the conclusion of the data base transaction if it fails
     */
    void registerPublishAfterTransactionFailure( List<SObject> events );
}