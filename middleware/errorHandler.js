// Error response structure
const createErrorResponse = (status, error, message, details = null) => ({
    status,
    error,
    message,
    ...(details && { details })
});

// Firebase error codes mapping
const firebaseErrors = {
    'auth/email-already-exists': {
        status: 409,
        error: 'Email Conflict',
        message: 'The email address is already in use'
    },
    'auth/invalid-email': {
        status: 400,
        error: 'Invalid Email',
        message: 'The email address is not valid'
    },
    'auth/operation-not-allowed': {
        status: 403,
        error: 'Operation Not Allowed',
        message: 'Email/password accounts are not enabled. Please contact support.'
    },
    'auth/weak-password': {
        status: 400,
        error: 'Weak Password',
        message: 'The password must be at least 6 characters long'
    },
    'auth/user-not-found': {
        status: 401,
        error: 'Authentication Failed',
        message: 'Invalid email or password'
    },
    'auth/wrong-password': {
        status: 401,
        error: 'Authentication Failed',
        message: 'Invalid email or password'
    },
    'auth/invalid-credential': {
        status: 401,
        error: 'Authentication Failed',
        message: 'Invalid credentials provided'
    },
    'auth/user-disabled': {
        status: 403,
        error: 'Account Disabled',
        message: 'This account has been disabled'
    },
    'auth/too-many-requests': {
        status: 429,
        error: 'Too Many Requests',
        message: 'Too many unsuccessful login attempts. Please try again later.'
    }
};

// Error handler middleware
const errorHandler = (err, req, res, next) => {
    console.error('Error details:', {
        code: err.code,
        message: err.message,
        stack: err.stack
    });

    // Handle Firebase Auth specific errors
    if (err.code && firebaseErrors[err.code]) {
        const { status, error, message } = firebaseErrors[err.code];
        return res.status(status).json(createErrorResponse(status, error, message));
    }

    // Handle validation errors
    if (err.name === 'ValidationError') {
        return res.status(400).json(
            createErrorResponse(400, 'Validation Error', err.message)
        );
    }

    // Handle other known errors
    if (err.status && err.error) {
        return res.status(err.status).json(
            createErrorResponse(err.status, err.error, err.message)
        );
    }

    // Default server error
    return res.status(500).json(
        createErrorResponse(
            500,
            'Internal Server Error',
            'An unexpected error occurred',
            process.env.NODE_ENV === 'development' ? err.stack : undefined
        )
    );
};

module.exports = {
    errorHandler,
    createErrorResponse
};
