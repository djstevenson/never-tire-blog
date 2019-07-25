/// <reference types="Cypress" />

import { TestEmailPage } from '../pages/test-email-page'
import { UserFactory   } from '../support/user-factory'
import { TestUserPage } from '../pages/test-user-page'

var userFactory = new UserFactory('regconf')

describe('Registration confirm/decline tests', function() {
    describe('New user confirms registration', function() {
        it('sees the right notification', function() {

            // TODO Replace this with a Cypress custom "command"
            //      see https://til.hashrocket.com/posts/92ienlwv9z-custom-cypress-commands
            const { user, page } = userFactory.getNextRegistered()

            page
                .visit()
                .register(user.getName(), user.getBadEmail(), user.getPassword())
            
            new TestEmailPage()
                .visit('registration', user.getName())
                .confirmRegistration()
                .assertFlash('Registration confirmed')
                .assertNotification('You have confirmed registration of this account.')
        })
        it('is confirmed', function() {
            const { user, page } = userFactory.getNextRegistered()

            page
                .visit()
                .register(user.getName(), user.getBadEmail(), user.getPassword())
            
            new TestEmailPage()
                .visit('registration', user.getName())
                .confirmRegistration()

            // User now confirmed
            new TestUserPage()
                .visit(user.getName())
                .assertIsConfirmed()
                .assertIsNotAdmin()
        })
    })

    describe('New user declines registration', function() {
        it('sees the right notification', function() {

            const { user, page } = userFactory.getNextRegistered()

            page
                .visit()
                .register(user.getName(), user.getBadEmail(), user.getPassword())
            
            new TestEmailPage()
                .visit('registration', user.getName())
                .declineRegistration()
                .assertFlash('Registration declined')
                .assertNotification('You have declined registration of this account.')
        })
        it('is deleted', function() {
            const { user, page } = userFactory.getNextRegistered()

            page
                .visit()
                .register(user.getName(), user.getBadEmail(), user.getPassword())
            
            new TestEmailPage()
                .visit('registration', user.getName())
                .declineRegistration()

            // User now deleted
            new TestUserPage()
                .assertNoUser(user.getName())
        })
    })
})