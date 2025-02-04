const express = require('express');
const router = express.Router();
const { auth } = require('../config/firebase');

// Validation middleware
const validateAuthInput = (req, res, next) => {
    const { email, password } = req.body;

    // Check for required fields
    if (!email || !password) {
        return res.status(400).json({
            status: 'error',
            code: 'MISSING_FIELDS',
            message: 'Both email and password are required fields'
        });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        return res.status(400).json({
            status: 'error',
            code: 'INVALID_EMAIL',
            message: 'Please provide a valid email address'
        });
    }

    // Validate password strength
    if (password.length < 6) {
        return res.status(400).json({
            status: 'error',
            code: 'WEAK_PASSWORD',
            message: 'Password must be at least 6 characters long'
        });
    }

    next();
};

// Error handler for async routes
const asyncHandler = (fn) => (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
};

// Signup endpoint
router.post('/signup', validateAuthInput, asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    try {
        const userRecord = await auth.createUser({
            email,
            password,
            emailVerified: false
        });

        res.status(201).json({
            status: 'success',
            message: 'User created successfully',
            data: {
                userId: userRecord.uid,
                email: userRecord.email,
                emailVerified: userRecord.emailVerified,
                createdAt: userRecord.metadata.creationTime
            }
        });

    } catch (error) {
        // Handle specific Firebase errors
        switch (error.code) {
            case 'auth/email-already-exists':
                res.status(409).json({
                    status: 'error',
                    code: 'EMAIL_EXISTS',
                    message: 'This email address is already registered'
                });
                break;
            case 'auth/invalid-email':
                res.status(400).json({
                    status: 'error',
                    code: 'INVALID_EMAIL',
                    message: 'The email address is not properly formatted'
                });
                break;
            case 'auth/operation-not-allowed':
                res.status(403).json({
                    status: 'error',
                    code: 'OPERATION_NOT_ALLOWED',
                    message: 'Email/password accounts are not enabled. Please contact support.'
                });
                break;
            default:
                res.status(500).json({
                    status: 'error',
                    code: 'SERVER_ERROR',
                    message: 'An error occurred while creating the account'
                });
        }
        console.error('Signup error:', error);
    }
}));

// Login endpoint
router.post('/login', validateAuthInput, asyncHandler(async (req, res) => {
    const { email } = req.body;

    try {
        // Verify user exists
        const userRecord = await auth.getUserByEmail(email);
        
        // Generate authentication token
        const customToken = await auth.createCustomToken(userRecord.uid);

        res.status(200).json({
            status: 'success',
            message: 'Login successful',
            data: {
                userId: userRecord.uid,
                token: customToken,
                user: {
                    email: userRecord.email,
                    emailVerified: userRecord.emailVerified,
                    displayName: userRecord.displayName || null,
                    photoURL: userRecord.photoURL || null,
                    createdAt: userRecord.metadata.creationTime,
                    lastSignInTime: userRecord.metadata.lastSignInTime
                }
            }
        });

    } catch (error) {
        // Handle specific Firebase errors
        switch (error.code) {
            case 'auth/user-not-found':
            case 'auth/wrong-password':
                res.status(401).json({
                    status: 'error',
                    code: 'INVALID_CREDENTIALS',
                    message: 'Invalid email or password'
                });
                break;
            case 'auth/user-disabled':
                res.status(403).json({
                    status: 'error',
                    code: 'ACCOUNT_DISABLED',
                    message: 'This account has been disabled'
                });
                break;
            case 'auth/too-many-requests':
                res.status(429).json({
                    status: 'error',
                    code: 'TOO_MANY_ATTEMPTS',
                    message: 'Too many unsuccessful login attempts. Please try again later.'
                });
                break;
            default:
                res.status(500).json({
                    status: 'error',
                    code: 'SERVER_ERROR',
                    message: 'An error occurred during login'
                });
        }
        console.error('Login error:', error);
    }
}));

module.exports = router;
