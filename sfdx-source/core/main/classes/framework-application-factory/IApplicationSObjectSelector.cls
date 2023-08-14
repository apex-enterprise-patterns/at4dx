/**
 * Copyright (c) 2020, John M. Daniel & John Storey
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
 *  IApplicationSObjectSelector
 */
public interface IApplicationSObjectSelector 
    extends fflib_ISObjectSelector
{
    /**
     * Returns the SelectSObjectsById(Set<Id>) query string.  Useful for Database.Querylocators
     */
    String selectSObjectsByIdQuery();

    /**
     * Selector Method Injection // executes an injected method against a pre-existing selector
     */
    List<SObject> selectInjection( System.Type methodClazz, ISelectorMethodParameterable params );

    /**
     * Selector Method Injection // executes an injected method against a pre-existing selector
     */
    Database.QueryLocator selectQueryLocatorInjection( System.Type methodClazzType, ISelectorMethodParameterable params );
    
    /**
     * Adds specified fields to the provided queryFactory preserving reference pathing.
     * Added to interface to allow use of newInstance() instantiation instead of "new class()" instantiation within selectors.
     */
    void configureQueryFactoryFields(fflib_QueryFactory queryFactory, String relationshipFieldPath);
    
    /**
     * Injects a queryFactory instance as a sub-select to the queryFactory in which this method resides.
     * Added to interface to allow use of newInstance() instantiation instead of "new class()" instantiation within selectors.
     */
    fflib_QueryFactory addQueryFactorySubselect(fflib_QueryFactory parentQueryFactory);
}