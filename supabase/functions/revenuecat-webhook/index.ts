// RevenueCat webhook -> Supabase profiles sync.
//
// Deploy:
//   supabase functions deploy revenuecat-webhook --no-verify-jwt
// Set secrets:
//   supabase secrets set REVENUECAT_WEBHOOK_AUTH="<shared-secret>"
//   (SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are injected automatically.)
//
// In the RevenueCat dashboard (Project settings -> Webhooks), point the URL at
// this function and set the Authorization header to the same shared secret.

import { createClient } from "jsr:@supabase/supabase-js@2";

const PRO_ENTITLEMENT_ID = "pro";

const LIFETIME_PRODUCT_IDS = new Set(["svar_pro_lifetime"]);
const YEARLY_PRODUCT_IDS = new Set(["svar_pro_yearly"]);
const MONTHLY_PRODUCT_IDS = new Set(["svar_pro_monthly"]);

// Event types that mean the user no longer has access.
const REVOKING_EVENTS = new Set([
  "EXPIRATION",
  "SUBSCRIPTION_PAUSED",
  "BILLING_ISSUE", // grace period ends -> treat as revoked once it fires expiration; conservative here
]);

function planFromProductId(productId: string | undefined): string | null {
  if (!productId) return null;
  if (LIFETIME_PRODUCT_IDS.has(productId)) return "lifetime";
  if (YEARLY_PRODUCT_IDS.has(productId)) return "yearly";
  if (MONTHLY_PRODUCT_IDS.has(productId)) return "monthly";
  return null;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // Verify the shared secret RevenueCat sends in the Authorization header.
  const expectedAuth = Deno.env.get("REVENUECAT_WEBHOOK_AUTH");
  const providedAuth = req.headers.get("Authorization");
  if (!expectedAuth || providedAuth !== expectedAuth) {
    return new Response("Unauthorized", { status: 401 });
  }

  let payload: Record<string, unknown>;
  try {
    payload = await req.json();
  } catch {
    return new Response("Bad request", { status: 400 });
  }

  const event = (payload.event ?? {}) as Record<string, unknown>;
  const type = event.type as string | undefined;
  const appUserId = event.app_user_id as string | undefined;
  const entitlementIds = (event.entitlement_ids as string[] | undefined) ?? [];
  const productId = event.product_id as string | undefined;
  const expirationMs = event.expiration_at_ms as number | undefined;

  // Ignore events that don't concern our Pro entitlement.
  if (!appUserId) {
    return new Response("ignored: no app_user_id", { status: 200 });
  }
  if (type === "TEST") {
    return new Response("ok: test event", { status: 200 });
  }

  const touchesPro =
    entitlementIds.length === 0 || entitlementIds.includes(PRO_ENTITLEMENT_ID);
  if (!touchesPro) {
    return new Response("ignored: not pro entitlement", { status: 200 });
  }

  const isRevoked = type ? REVOKING_EVENTS.has(type) : false;
  const isLifetime =
    !isRevoked &&
    (type === "NON_RENEWING_PURCHASE" ||
      (productId ? LIFETIME_PRODUCT_IDS.has(productId) : false));

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const update = {
    user_id: appUserId,
    entitlement: isRevoked ? "free" : "pro",
    plan: isRevoked ? null : planFromProductId(productId),
    is_lifetime: isLifetime,
    pro_expires_at:
      isRevoked || isLifetime || !expirationMs
        ? null
        : new Date(expirationMs).toISOString(),
    rc_app_user_id: appUserId,
    updated_at: new Date().toISOString(),
  };

  const { error } = await supabase
    .from("profiles")
    .upsert(update, { onConflict: "user_id" });

  if (error) {
    console.error("profiles upsert failed", error);
    return new Response(`db error: ${error.message}`, { status: 500 });
  }

  return new Response("ok", { status: 200 });
});
