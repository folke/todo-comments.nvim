-- tests/sample.lua
-- Test sample file for todo-comments.nvim with subtasks, multiline context, and folding

-- 1. Traditional Single-Line comments (no subtasks)
-- FIX: Fix memory leak in websocket connection handler
-- HACK: Temporary workaround for upstream dependency regression

-- 2. Informative Multiline Context Blocks (Lines hidden when folded)
-- WARN: Critical security deprecation notice
-- This API v1 will be sunset next quarter.
-- Migrate all internal callers to gRPC client.
-- Notify DevOps team before production deploy.

-- NOTE: Architecture and Design Decision
-- Using in-memory B+ tree for indexing comments.
-- Reduces search latency to logarithmic O(log N) time.

-- 3. TODO Block with Tasks in Progress (2 of 4 done)
-- TODO: Implement two-factor authentication (2FA)
-- [x] 1. Generate TOTP secret key and render QR code
-- [x] 2. Create validation middleware for 6-digit tokens
-- [/] 3. Build backup recovery codes endpoint (in progress)
-- [ ] 4. Account recovery and email reset flow

-- 4. 100% Completed TODO Block (3 of 3 done)
-- TODO: Database and Query Optimization
-- [x] Add composite index on users(email, status)
-- [x] Cache active sessions in Redis
-- [x] Eliminate N+1 queries in post list

-- 5. Subtasks with Indentation and Markdown List Format (- [ ])
-- TODO: Migrate UI components to Tailwind v4
--   - [x] Configure new theme tokens and colors
--   - [/] Migrate Button and Dropdown components
--   - [ ] Migrate Modal and Dialog components
--   - [ ] Update Storybook and visual regression tests

-- 6. Single-Line Task with Checkbox (0 of 1)
-- TODO: [ ] Create seed script for mock test data

-- 7. Subtasks inside Function Bodies
local function process_payment(user_id, amount)
  -- TODO: Payment processing and validation pipeline
  -- [x] Validate available user balance
  -- [/] Dispatch signed payload to payment gateway
  -- [ ] Issue electronic invoice
  -- [ ] Notify user via webhook and email
  
  if amount <= 0 then
    -- WARN: Invalid transaction attempt detected
    -- Log security audit event with client IP.
    -- Temporarily throttle repeated attempts.
    return false
  end

  -- 8. Single-Line TODO directly followed by executable code (0 context lines)
  -- TODO: Single line todo without any continuation comments
  local transaction_id = "tx_" .. tostring(user_id)

  return true
end
