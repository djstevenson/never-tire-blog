/// <reference types="Cypress" />

import { ListSongsPage  } from '../pages/song/list-songs-page'
import { UserFactory    } from '../support/user-factory'
import { SongFactory    } from '../support/song-factory'
import { CreateSongPage } from '../pages/song/create-song-page'

var label = 'createsong'
var userFactory = new UserFactory(label)
var songFactory = new SongFactory(label)

// Create songs via the form rather than
// the test-mode shortcut as, really, we're
// testing the admin UI here.
function createSong() {
    const song = songFactory.getNext()

    new CreateSongPage()
        .visit()
        .createSong(song.asArgs())

    return song
}

describe('Create Song tests', function() {
    describe('Form validation', function() {
        it('Create song page has right title', function() {

            userFactory.getNextLoggedInUser(true)

            new CreateSongPage()
                .visit()
                .assertTitle('New song')
        })

        it('Form shows right errors with empty input', function() {

            userFactory.getNextLoggedInUser(true)

            new CreateSongPage()
                .visit()
                .createSong({})
                .assertFormError('title',           'Required')
                .assertFormError('artist',          'Required')
                .assertFormError('album',           'Required')
                .assertFormError('countryId',       'Required')
                .assertFormError('releasedAt',      'Required')
                .assertFormError('summaryMarkdown', 'Required')
                .assertFormError('fullMarkdown',    'Required')
        })

        it('Form shows right errors with invalid input', function() {

            // There's deliberately minimal validation, no reason
            // why I shouldn't be able to enter a single-character
            // title for example.
            userFactory.getNextLoggedInUser(true)

            new CreateSongPage()
                .visit()
                .createSong({
                    title:           'a',
                    artist:          'a',
                    album:           'a',
                    countryId:       'a',
                    releasedAt:      'a',
                    summaryMarkdown: 'a',
                    fullMarkdown:    'a'
                })
                .assertNoFormError('title')
                .assertNoFormError('artist')
                .assertNoFormError('album')
                .assertFormError('countryId', 'Invalid number')
                .assertNoFormError('releasedAt')
                .assertNoFormError('summaryMarkdown')
                .assertNoFormError('fullMarkdown')

            new CreateSongPage()
                .visit()
                .createSong({
                    title:           'a',
                    artist:          'a',
                    album:           'a',
                    countryId:       '0',
                    releasedAt:      'a',
                    summaryMarkdown: 'a',
                    fullMarkdown:    'a'
                })
                .assertFormError('countryId', 'Country id 0 does not exist')
        })
    })

    describe('Song list', function() {
        it('shows multiple songs in newest-first order', function() {
            songFactory.resetDatabase()

            userFactory.getNextLoggedInUser(true)

            const song1 = createSong()
            new ListSongsPage()
                .visit()
                .assertSongCount(1)
                .getRow(1)
                    .assertText('title', song1.getTitle())

            // Now create another song, it should go to the top
            const song2 = createSong()

            const page2 = new ListSongsPage()
                .visit()
                .assertSongCount(2)
            
            page2.getRow(1).assertText('title', song2.getTitle())  // Song 2 first (woo hoo etc)
            page2.getRow(2).assertText('title', song1.getTitle())  // Song 1 second
        })

    })

})
