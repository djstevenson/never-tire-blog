import { FormBase   } from './form-base'
import { FormField  } from './form-field'
import { FormButton } from './form-button'

export class CreateLinkForm extends FormBase {
    constructor() {
        super();
        this._fields.name     = new FormField('text', 'add-link-name')
        this._fields.url      = new FormField('text', 'add-link-url')
        this._fields.priority = new FormField('text', 'add-link-priority')
        this._fields.extras   = new FormField('text', 'add-link-extras')

        this._buttons.submit = new FormButton('create-link-button')
    }
}
