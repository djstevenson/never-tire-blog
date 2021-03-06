/// <reference types="Cypress" />

import { UserFactory    } from '../support/user-factory'
import { SongFactory    } from '../support/song-factory'
import { ListSongsPage  } from '../pages/song/list-songs-page'
import { CreateSongPage } from '../pages/song/create-song-page'
import { EditSongPage   } from '../pages/song/edit-song-page'
import { HomePage       } from '../pages/home-page'

const label = 'listsong';
const userFactory = new UserFactory(label);
const songFactory = new SongFactory(label);

beforeEach( () => {
    cy.resetDatabase()
})

context('Song CRUD tests', () => {

    describe('List-songs ordering etc', () => {
        it('Song list starts empty', () => {

            userFactory.getNextSignedInUser(true)

            new ListSongsPage()
                .visit()
                .assertEmpty()
        })

        it('shows songs in creation order, regardless of publication status', () => {

            const user = userFactory.getNextSignedInUser(true)

            const song1 = songFactory.getNextSong(user)
            const song2 = songFactory.getNextSong(user)
            const song3 = songFactory.getNextSong(user)

            // In order of creation, newest first
            let page = new ListSongsPage()
                .visit()
                .assertSongCount(3)
                .assertSongTitle(1, song3.getTitle())
                .assertSongTitle(2, song2.getTitle())
                .assertSongTitle(3, song1.getTitle())

            // Publish two songs and check order remains the same
            song1.publish();
            song3.publish();

            page
                .visit()
                .assertSongCount(3)
                .assertSongTitle(1, song3.getTitle())
                .assertSongTitle(2, song2.getTitle())
                .assertSongTitle(3, song1.getTitle())
        })


    })

    describe('Publish/unpublish button', () => {
        it('Can publish/unpublish songs from the song list', () => {

            const user = userFactory.getNextSignedInUser(true)

            songFactory.getNextSong(user)
            songFactory.getNextSong(user)

            // Both songs should be unpublished
            new ListSongsPage()
                .visit()
                .assertSongCount(2)
                .assertSongUnpublished(1)
                .assertSongUnpublished(2)

                // Publish the 2nd one and re-check
                .publishSong(2)
                .assertSongUnpublished(1)
                .assertSongPublished(2)

                // Publish the 1st one and re-check
                .publishSong(1)
                .assertSongPublished(1)
                .assertSongPublished(2)

                // Check that we can unpublish too
                .unpublishSong(2)
                .assertSongPublished(1)
                .assertSongUnpublished(2)

        })
    })

    describe('Create form validation', () => {
        it('Create song page has right title', () => {

            userFactory.getNextSignedInUser(true)

            new CreateSongPage()
                .visit()
                .assertTitle('New song')
        })

        it('Create song form can be cancelled', () => {

            const user  = userFactory.getNextSignedInUser(true)
            songFactory.getNextSong(user)

            new CreateSongPage()
                .visit()
                .cancel()
                .assertSongCount(1)
        })

        it('Create song form shows right errors with empty input', () => {

            userFactory.getNextSignedInUser(true)

            new CreateSongPage()
                .visit()
                .createSong({})
                .assertFormError('title',           'Required')
                .assertFormError('artist',          'Required')
                .assertFormError('album',           'Required')
                .assertFormError('image',           'Required')
                .assertFormError('releasedAt',      'Required')
                .assertFormError('summaryMarkdown', 'Required')
                .assertFormError('fullMarkdown',    'Required')
        })

    })

    describe('Edit form validation', () => {
        it('Edit song page has right title', () => {

            const user = userFactory.getNextSignedInUser(true)
            const song1 = songFactory.getNextSong(user)

            new ListSongsPage()
                .visit()
                .edit(1)
                .assertTitle(`Edit song: ${song1.getTitle()}`)
        })

        it('Edit song form can be cancelled', () => {

            const user  = userFactory.getNextSignedInUser(true)
            songFactory.getNextSong(user)

            new ListSongsPage()
                .visit()
                .edit(1)
                .cancel()
                .assertSongCount(1)
        })

        it('Edit song form shows right errors with empty input', () => {

            const user = userFactory.getNextSignedInUser(true)
            songFactory.getNextSong(user)

            new ListSongsPage()
                .visit()
                .edit(1)
                .editSong({
                    title:           '',
                    artist:          '',
                    album:           '',
                    image:           '',
                    country:         '',
                    releasedAt:      '',
                    summaryMarkdown: '',
                    fullMarkdown:    ''
                })
                .assertFormError('title',           'Required')
                .assertFormError('artist',          'Required')
                .assertFormError('album',           'Required')
                .assertFormError('image',           'Required')
                .assertFormError('country',         'Required')
                .assertFormError('releasedAt',      'Required')
                .assertFormError('summaryMarkdown', 'Required')
                .assertFormError('fullMarkdown',    'Required')
        })
    })

    describe('Song list - new song goes into right place in list', () => {
        it('new song title shows up in song list', () => {

            const user = userFactory.getNextSignedInUser(true)
            const song1 = songFactory.getNextSong(user)

            const newTitle = 'x' + song1.getTitle();
            const listPage = new ListSongsPage().visit()
            listPage
                .edit(1)
                .editSong({ title: newTitle })

            listPage
                .assertSongTitle(1, newTitle)
        })

        it('song edit does not affect position in song list', () => {

            const user = userFactory.getNextSignedInUser(true)
            const song1 = songFactory.getNextSong(user)
            const song2 = songFactory.getNextSong(user)
            const song3 = songFactory.getNextSong(user)

            const newTitle = 'x' + song2.getTitle();
            const listPage = new ListSongsPage()
                .visit()
                .assertSongCount(3)
                .assertSongTitle(1, song3.getTitle())
                .assertSongTitle(2, song2.getTitle())
                .assertSongTitle(3, song1.getTitle())

            // Edit the title of song 2
            listPage
                .edit(2)
                .editSong({ title: newTitle });

            // Row 1 = song3, row 2 = song2, row 3 = song1
            listPage
                .visit()
                .assertSongCount(3)
                .assertSongTitle(1, song3.getTitle())
                .assertSongTitle(2, newTitle)
                .assertSongTitle(3, song1.getTitle())
        })

        // TODO Refactor to make this readable! This is a mess
        it('song edit does affect not publication status', () => {

            const user = userFactory.getNextSignedInUser(true)
            const song1 = songFactory.getNextSong(user)

            const listPage = new ListSongsPage()

            listPage
                .visit()
                .assertSongUnpublished(1)
                .edit(1)

            const newTitle = 'x' + song1.getTitle();
            new EditSongPage().editSong({ title: newTitle })

            // Now publish it, edit again, and re-check status
            const newTitle2 = 'xx' + song1.getTitle();
            listPage
                .publishSong(1)
                .assertSongPublished(1)
                .edit(1)
                .editSong({ title: newTitle2 })

            listPage.assertSongPublished(1)
        })

        it('Front page ordered by published_date', () => {
            const user = userFactory.getNextSignedInUser(true)

            // Songs will be published in the order (from oldest):
            // song 2
            // song 1
            // song 4 NOT PUBLISHED
            // song 5
            // song 3
            // song 6
            //
            // Therefore, front page should see 6 at the top, then
            // 3 then 5. The 'previous' links should contain 1 then 2.
            //
            // The 'song list' admin page is ordered by id desc, however

            const song1 = songFactory.getNextSong(user)
            const song2 = songFactory.getNextSong(user)
            const song3 = songFactory.getNextSong(user)
            const song4 = songFactory.getNextSong(user)
            const song5 = songFactory.getNextSong(user)
            const song6 = songFactory.getNextSong(user)
            
            song2.publish()
            song1.publish()
            song5.publish()
            song3.publish()
            song6.publish()

            // Check all six are in the admin list in right order
            new ListSongsPage()
                .visit()
                .assertSongTitle(1, song6.getTitle())
                .assertSongTitle(2, song5.getTitle())
                .assertSongTitle(3, song4.getTitle())
                .assertSongTitle(4, song3.getTitle())
                .assertSongTitle(5, song2.getTitle())
                .assertSongTitle(6, song1.getTitle())
            
            const home = new HomePage()
                .visit()
                .assertSongCount(3)     // Cos we only show three in full
                .assertSongLinkCount(2) // The rest
            
            // Check the three highlighted songs in right order
            home.findSong(1)
                .assertSongTitle(song6.getTitle())

            home.findSong(2)
                .assertSongTitle(song3.getTitle())

            home.findSong(3)
                .assertSongTitle(song5.getTitle())

            // Check the two link songs in right order
            home.findLinkSong(1)
                .assertSongTitle(song1.getTitle())

            home.findLinkSong(2)
                .assertSongTitle(song2.getTitle())

            // Open the first song, and follow the 'previous' links in order
            home
                .findSong(1).visit()                // Song 6
                .clickPrevSong()
                .assertSongTitle(song3.getTitle())  // Song 6 prev is song 3

                .clickPrevSong()
                .assertSongTitle(song5.getTitle())  // Song 3 prev is song 5

                .clickPrevSong()
                .assertSongTitle(song1.getTitle())  // Song 5 prev is song 1

                .clickPrevSong()
                .assertSongTitle(song2.getTitle())  // Song 1 prev is song 2
                .assertNoPrevSong()                 // Chain ends here

                // Follow the 'next' links back to the start
                .clickNextSong()
                .assertSongTitle(song1.getTitle())  // Song 2 prev is song 1

                .clickNextSong()
                .assertSongTitle(song5.getTitle())  // Song 1 prev is song 5

                .clickNextSong()
                .assertSongTitle(song3.getTitle())  // Song 5 prev is song 3

                .clickNextSong()
                .assertSongTitle(song6.getTitle())  // Song 3 prev is song 6
                .assertNoNextSong()                 // Chain ends here

        })
    })

    describe('Delete songs from song-list page', () => {
        it('Can cancel an attempt to delete a song', () => {

            const user = userFactory.getNextSignedInUser(true)

            const song1 = songFactory.getNextSong(user)
            new ListSongsPage()
                .visit()
                .assertSongCount(1)
                .delete(1)
                .cancel()
                .assertSongCount(1)
        })

        it('Can delete a published song', () => {

            const user = userFactory.getNextSignedInUser(true)

            const song1 = songFactory.getNextSong(user)
            const page = new ListSongsPage()
                .visit()
                .assertSongCount(1)

            page
                .delete(1)    // Requests delete form
                .deleteSong() // Hits confirm

            page.assertEmpty()
        })

        it('Can delete an unpublished song', () => {

            const user = userFactory.getNextSignedInUser(true)

            const song1 = songFactory.getNextSong(user)
            const song2 = songFactory.getNextSong(user)
            const page = new ListSongsPage()
                .visit()
                .assertSongCount(2)
                .assertSongTitle(1, song2.getTitle()) // song 2 now in row 1

            page
                .delete(1)
                .deleteSong()

            page
                .assertSongCount(1)
                .assertSongTitle(1, song1.getTitle()) // song 1 now in row 1
        })

    })

    describe('Editing links re-renders song', () => {
        it('Reference a link that does not exist, then create it', () => {
            const user = userFactory.getNextSignedInUser(true)

            const song1 = songFactory.getNextSong(user)
            
            // Edit song to reference a link we have not created yet
            const newMarkdown = "abc ^^link1^^ def"
            const listPage = new ListSongsPage()
            listPage
                .visit()
                .edit(1)
                .editSong({ fullMarkdown: newMarkdown });
            
            // View it and check rendered html shows placeholder
            listPage
                .visit()
                .view(1)
                .assertSongTitle(song1.getTitle())
                .assertDescriptionContains("LINK IDENTIFIER NOT FOUND: link1")
            
            // Edit the link
            const url1 = "https://ytfc.com/link1"
            const desc1 = "link1 desc"
            listPage
                .visit()
                .links(1)
                .clickNew()
                .createLink({
                    embed_identifier: "link1",
                    embed_url: url1,
                    embed_description: desc1,
                    embed_class: "Default",
                    list_priority: '0'
                })
            
            // Revisit song page and check link
            listPage
                .visit()
                .view(1)
                .assertDescriptionLink(1, url1, desc1)
        })
    })

})
