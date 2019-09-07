/// <reference types="Cypress" />

import { ListSongsPage     } from '../../../pages/song/list-songs-page'
import { ListSongLinksPage } from '../../../pages/song/link/list-song-links-page'
import { UserFactory       } from '../../../support/user-factory'
import { SongFactory       } from '../../../support/song-factory'

const label = 'listlinks'
const userFactory = new UserFactory(label)
const songFactory = new SongFactory(label)

context('List Song Links test', () => {
    describe('Initial song links', () => {
        it('List song links page has right title, and empty links list', () => {

            // Create a song
            const user = userFactory.getNextLoggedInUser(true)
            const song1 = songFactory.getNextSong(user)
        
            // Go to the list-links page
            new ListSongsPage()
                .visit()
                .getRow(1)
                .click('links')
                   
            // Assert list is empty
            new ListSongLinksPage()
                .assertTitle(`Links for ${song1.getTitle()}`)
                .assertEmpty()
        })
    })

    // Other tests are in the create/edit/etc spec files

})

