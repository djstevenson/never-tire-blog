package NeverTire::Form::Render::Input::TextArea;
use Moose::Role;
use namespace::autoclean;

with 'NeverTire::Form::Render::Input::Generic';

sub render {
    my ($self, $form) = @_;

    my $name        = $self->name;
    my $id          = $self->_name_to_id($form, $name);
    my $label       = $self->label;
    my $placeholder = $self->placeholder;

	my $value       = $self->has_value ? $self->value : '';
    my $input_class = 'form-control';
    my $error_class = '';
    my $error_id    = 'error-' . $id;
    my $text        = '';
    if ($self->has_error) {
        $text = $self->error;
        $input_class .= ' is-invalid';
        $error_class = 'text-danger';
    }
    my $error = qq{<span id="${error_id}" class="${error_class}">${text}</span>};

    my $autofocus = $self->autofocus ? 'autofocus="autofocus"' : '';

    my $options = $self->_get_options;
	my $rows = exists $options->{rows} ? $options->{rows} : 6;

    return qq{
		<div class="form-group">
			<label for="${id}">${label}</label>
			<textarea id="${id}" name="${name}" $autofocus class="${input_class}" rows="${rows}" placeholder="${placeholder}">${value}</textarea>
			${error}
		</div>
	};
}

1;
