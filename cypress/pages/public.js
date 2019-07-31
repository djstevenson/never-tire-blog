export class Public {
    getForm() {
        return this._form
    }

    assertTitle(expected) {
        cy.title().should('eq', expected)
        return this
    }

    assertLoggedOut() {
        cy.get('a.login-link').contains('Login')
        return this
    }

    assertLoggedInAs(username) {
        cy.get('span.user-name').contains(username)
        return this
    }

    assertNotification(title, message) {
        cy
            .get('h2.notification-title')
            .contains(title)
            .get('div.notification > p:first-child')
            .contains(message);
        return this
    }

    assertFlash(expected) {
        cy
            .get('div#flash-msg')
            .contains(expected)
        return this
    }

    assertNoFormError(key) {
        this.getForm().getError(key).should('be.empty')
        return this
    }

    assertFormError(key, expected) {
        this.getForm().getError(key).contains(expected)
        return this
    }

    visit() {
        cy.visit(this.pageUrl())
        return this
    }

    assertVisitError(err) {
        cy
            .request({
                url:              this.pageUrl(),
                failOnStatusCode: false
            })
            .its('status')
            .should('eq', err)
    }

}
