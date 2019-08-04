import { FormBase   } from '../forms/form-base'
import { FormField  } from '../forms/form-field'
import { FormButton } from '../forms/form-button'

export class CreateSongForm extends FormBase {
    constructor() {
        super();
        this._fields.title           = new FormField('text',     'new-song-title')
        this._fields.artist          = new FormField('text',     'new-song-artist')
        this._fields.album           = new FormField('text',     'new-song-album')
        this._fields.countryId       = new FormField('text',     'new-song-country-id')
        this._fields.releasedAt      = new FormField('text',     'new-song-released-at')
        this._fields.summaryMarkdown = new FormField('textarea', 'new-song-summary-markdown')
        this._fields.fullMarkdown    = new FormField('textarea', 'new-song-full-markdown')

        this._buttons.submit         = new FormButton('create-song-button')
    }
}