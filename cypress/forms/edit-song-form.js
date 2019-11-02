import { FormBase   } from './form-base'
import { FormField  } from './form-field'
import { FormButton } from './form-button'

export class EditSongForm extends FormBase {
    constructor() {
        super();
        this._fields.title           = new FormField('text',     'edit-song-title')
        this._fields.artist          = new FormField('text',     'edit-song-artist')
        this._fields.album           = new FormField('text',     'edit-song-album')
        this._fields.image           = new FormField('text',     'edit-song-image')
        this._fields.countryId       = new FormField('select',   'edit-song-country-id')
        this._fields.releasedAt      = new FormField('text',     'edit-song-released-at')
        this._fields.summaryMarkdown = new FormField('textarea', 'edit-song-summary-markdown')
        this._fields.fullMarkdown    = new FormField('textarea', 'edit-song-full-markdown')

        this._buttons.submit         = new FormButton('update-song-button')
        this._buttons.cancel         = new FormButton('cancel-button')
    }
}
