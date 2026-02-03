from flask import Flask, render_template
import os
from utils.i18n import t as _t
import logging

# fail-fast checks for production secrets
try:
    from authentication.jwt_utils import ensure_secret_configured
except Exception:
    ensure_secret_configured = None

try:
    app = Flask(__name__)
except Exception:
    app = None


if app:
    # Production safety: ensure JWT_SECRET_KEY is set to a non-default value.
    try:
        # Only enforce in production environment; warn otherwise.
        if os.getenv("FLASK_ENV") == "production" and ensure_secret_configured:
            ensure_secret_configured(raise_on_default=True)
        elif ensure_secret_configured:
            try:
                ok = ensure_secret_configured(raise_on_default=False)
                if not ok:
                    logging.warning("JWT secret is using default value; set JWT_SECRET_KEY for production.")
            except Exception:
                pass
    except RuntimeError:
        # Re-raise to stop startup in production with insecure defaults
        raise

    @app.route("/")
    def index():
        return render_template("index.html")

    @app.context_processor
    def inject_i18n():
        # expose `t` to templates; will use LANG env by default
        return {"t": _t}

    # register authentication blueprint if available
    try:
        from authentication.routes import auth_bp

        app.register_blueprint(auth_bp)
    except Exception:
        # blueprint not available or failed to import; continue without it
        pass
    # register payments blueprint if available
    try:
        from integrations.stripe_routes import payments_bp

        app.register_blueprint(payments_bp)
    except Exception:
        pass

    # register organizations blueprint if available
    try:
        from organizations import orgs_bp

        app.register_blueprint(orgs_bp)
    except Exception:
        pass
    # register chat blueprint if available
    try:
        from wed.chat_routes import chat_bp

        app.register_blueprint(chat_bp)
    except Exception:
        pass

    # register human review blueprint if available
    try:
        from wed.review_routes import bp as review_bp

        app.register_blueprint(review_bp)
    except Exception:
        pass
    
    # register streaming & observability blueprint if available
    try:
        from observability.streaming_routes import streaming_bp

        app.register_blueprint(streaming_bp)
    except Exception:
        pass

    @app.route('/payments/example')
    def stripe_example():
        key = os.getenv('STRIPE_PUBLISHABLE_KEY', 'pk_test_XXXXXXXXXXXXXXXXXXXXXXXX')
        return render_template('stripe_example.html', stripe_publishable_key=key)


else:
    def index():
        return "Flask not installed. Install with 'pip install flask' to run this app."


if __name__ == "__main__":
    if app:
        app.run(debug=True, host="0.0.0.0", port=5000)
    else:
        print(index())
