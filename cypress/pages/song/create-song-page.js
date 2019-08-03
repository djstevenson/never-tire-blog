import { Admin          } from '../../pages/admin'
import { CreateSongForm } from '../../forms/create-song-form'

export class CreateSongPage extends Admin {
    pageUrl() {
        return '/song/create'
    }

    constructor() {
        super()
        this._form = new CreateSongForm()
    }
}
