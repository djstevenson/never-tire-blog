package SongsToTheSiren::Form::Render::Input::Password;
use Moose::Role;
use namespace::autoclean;

with 'SongsToTheSiren::Form::Render::Input::Generic';

sub render{
	my ($self, $form) = @_;
    return $self->_input_render($form, 'password');
}

1;