const loginCommands = {
	login(username, password) {
		this
			.setValue('@usernameField', username)
			.setValue('@passwordField', password)
			.click('@submit');
	},
};

module.exports = {
	url: function() {
		// return `${this.api.launchUrl}/user/login`;
		return 'http://localhost:3000/user/login';
	},
	sections: {
		loginForm: {
			selector: '#login-form',
			elements: {
				usernameField: '#user-login-name',
				passwordField: '#user-login-password',
				usernameError: '#error-user-login-name',
				passwordError: '#error-user-login-password',
				submit: '#login-button',
			},
			commands: [loginCommands],
		},
	},
};
