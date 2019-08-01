export class Song {
    constructor(baseName) {
        this._title     = 'Title ' + baseName
        this._artist    = 'Artist ' + baseName
        this._album     = 'Album ' + baseName
        this._countryId = 1
        this._releasedAt = 'Release ' + baseName
        this._summary   = 'Summary ' + baseName
        this._full      = 'Full ' + baseName
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
}

