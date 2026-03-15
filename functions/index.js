const admin = require("firebase-admin");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {logger} = require("firebase-functions");

admin.initializeApp();

exports.sendPushForNotification = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) {
      return;
    }

    const recipientIds = await resolveNotificationRecipients(data);
    if (!recipientIds.length) {
      logger.info("No notification recipients resolved", data);
      return;
    }

    const tokens = await loadTokensByUserIds(recipientIds);
    if (!tokens.length) {
      logger.info("No notification tokens found", {recipientIds});
      return;
    }

    await sendMulticast(tokens, {
      notification: {
        title: String(data.title || "Intern Tracker"),
        body: String(data.desc || data.message || "You have a new update."),
      },
      data: {
        type: String(data.type || "general"),
        notificationId: event.params.notificationId,
        senderRole: String(data.senderRole || ""),
      },
      android: {
        priority: "high",
        notification: {
          channelId: "intern_tracker_alerts",
          sound: "default",
        },
      },
    });
  },
);

exports.sendPushForChatMessage = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message) {
      return;
    }

    const chatId = event.params.chatId;
    const chatSnapshot = await admin.firestore().collection("chats").doc(chatId).get();
    if (!chatSnapshot.exists) {
      return;
    }

    const chatData = chatSnapshot.data() || {};
    const senderId = String(message.senderId || "").trim();
    const participantIds = Array.isArray(chatData.participantIds)
      ? chatData.participantIds.map((value) => String(value))
      : [];
    const recipientIds = participantIds.filter((id) => id && id !== senderId);

    if (!recipientIds.length) {
      return;
    }

    const tokens = await loadTokensByUserIds(recipientIds);
    if (!tokens.length) {
      logger.info("No chat tokens found", {chatId, recipientIds});
      return;
    }

    const senderName = String(message.senderName || "Someone");
    const chatTitle = String(chatData.title || senderName);
    const body = String(message.text || "Sent a photo");

    await sendMulticast(tokens, {
      notification: {
        title: chatTitle,
        body,
      },
      data: {
        type: "chat",
        chatId,
        messageId: event.params.messageId,
        senderId,
        senderName,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "intern_tracker_alerts",
          sound: "default",
        },
      },
    });
  },
);

async function resolveNotificationRecipients(data) {
  const recipientId = String(data.recipientId || "").trim();
  if (recipientId) {
    return [recipientId];
  }

  const target = String(data.target || "").trim().toLowerCase();
  if (target === "all") {
    return await loadAllUserIds();
  }

  if (target === "student" || target === "students") {
    const senderId = String(data.senderId || "").trim();
    if (!senderId) {
      return [];
    }

    const senderSnapshot = await admin.firestore().collection("user").doc(senderId).get();
    if (!senderSnapshot.exists) {
      return [];
    }

    const sender = senderSnapshot.data() || {};
    const senderRole = String(sender.role || "").trim().toLowerCase();

    if (senderRole === "mentor") {
      const mentorId = String(sender.mentorId || "").trim();
      if (!mentorId) {
        return [];
      }
      return await loadUserIdsByField("companyMentorId", mentorId);
    }

    if (senderRole === "faculty") {
      const facultyId = String(sender.facultyId || "").trim();
      if (!facultyId) {
        return [];
      }
      return await loadUserIdsByField("facultyId", facultyId);
    }

    return [];
  }

  if (target) {
    return await loadUserIdsByField("role", target);
  }

  return [];
}

async function loadAllUserIds() {
  const snapshot = await admin.firestore().collection("user").get();
  return snapshot.docs.map((doc) => doc.id);
}

async function loadUserIdsByField(field, value) {
  const snapshot = await admin.firestore().collection("user").where(field, "==", value).get();
  return snapshot.docs.map((doc) => doc.id);
}

async function loadTokensByUserIds(userIds) {
  const uniqueUserIds = [...new Set(userIds.filter(Boolean))];
  const tokenSet = new Set();

  for (const userId of uniqueUserIds) {
    const snapshot = await admin.firestore().collection("user").doc(userId).get();
    if (!snapshot.exists) {
      continue;
    }

    const data = snapshot.data() || {};
    const tokens = Array.isArray(data.fcmTokens) ? data.fcmTokens : [];
    for (const token of tokens) {
      if (typeof token === "string" && token.trim()) {
        tokenSet.add(token.trim());
      }
    }
  }

  return [...tokenSet];
}

async function sendMulticast(tokens, payload) {
  const chunks = [];
  for (let index = 0; index < tokens.length; index += 500) {
    chunks.push(tokens.slice(index, index + 500));
  }

  for (const chunk of chunks) {
    const response = await admin.messaging().sendEachForMulticast({
      tokens: chunk,
      ...payload,
    });

    response.responses.forEach((result, index) => {
      if (!result.success) {
        logger.warn("Push send failed", {
          token: chunk[index],
          error: result.error?.message,
        });
      }
    });
  }
}
