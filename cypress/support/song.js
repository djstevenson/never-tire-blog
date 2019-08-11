export class Song {
    constructor(baseName) {
        this._title      = `Title ${baseName}`
        this._artist     = `Artist ${baseName}`
        this._album      = `Album ${baseName}`
        this._image      = `http://example.com/${baseName}.jpg`
        this._countryId  = 1
        this._releasedAt = `Release ${baseName}`
        this._summary    = `Summary ${baseName}`
        this._full       = `Full ${baseName}`
    }

    getTitle() {
        return this._title
    }

    getArtist() {
        return this._artist
    }

    getAlbum() {
        return this._album
    }

    getImage() {
        return this._image
    }

    getCountryId() {
        return this._countryId
    }

    getReleasedAt() {
        return this._releasedAt
    }

    getSummary() {
        return this._summary
    }

    getFull() {
        return this._full
    }

    // TODO Do away with these 'test page' hacks.
    //      If we give admin access to emails table,
    //      we can do all we need from normal interface
    publish() {
        cy.publishSong(this.getTitle(), 1)
    }

    unpublish() {
        cy.publishSong(this.getTitle(), 0)
    }

    asArgs() {
        return {
            title:            this.getTitle(),
            artist:           this.getArtist(),
            album:            this.getAlbum(),
            image:            this.getImage(),
            countryId:        this.getCountryId(),
            releasedAt:       this.getReleasedAt(),
            summaryMarkdown:  this.getSummary(),
            fullMarkdown:     this.getFull(),
        }
    }
}

