<template>
  <div class="elevator-root" v-if="visible">
    <div class="elevator-backdrop" @click="handleBackdropClick"></div>
    <div class="elevator-panel">
      <div class="elevator-top">
        <div class="elevator-display">
          <div class="elevator-display-screen">
            <div class="elevator-display-arrow">▲</div>
            <div class="elevator-display-floor">
              {{ displayFloor || '' }}
            </div>
          </div>
        </div>
        <div class="elevator-brand">ELEVATOR</div>
      </div>

      <main class="elevator-body">
        <ul class="elevator-floors" :class="floorsLayoutClass">
          <li
            v-for="(floor, index) in displayButtons"
            :key="floor.__placeholder ? `placeholder-${index}` : (floor.id || floor.label)"
            class="elevator-floor-item"
          >
            <button
              type="button"
              class="elevator-floor-button"
              :class="{ 'is-placeholder': floor.__placeholder }"
              @click="!floor.__placeholder && selectFloor(floor)"
              :disabled="floor.__placeholder"
            >
              <span v-if="!floor.__placeholder" class="elevator-floor-label">
                {{ floor.label || floor.id }}
              </span>
            </button>
          </li>
        </ul>

        <div v-if="bellButton" class="elevator-bell">
          <button
            type="button"
            class="elevator-floor-button elevator-bell-button"
            @click="selectFloor(bellButton)"
          >
            <span class="elevator-floor-label">
              {{ bellButton.label || bellButton.id || 'BELL' }}
            </span>
          </button>
        </div>
      </main>

      <div class="elevator-bottom">
        <div class="elevator-bottom-panel">
          <div class="elevator-bottom-line">PASSENGER LIFT</div>
          <div class="elevator-bottom-line">15 PERSONS</div>
          <div class="elevator-bottom-line">1150 kg</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from "vue";

const visible = ref(false);
const elevatorId = ref(null);
const label = ref("Elevator");
const description = ref("");
const floors = ref([]);
const displayFloor = ref("");

const resourceName =
  typeof GetParentResourceName === "function"
    ? GetParentResourceName()
    : "nox-elevator";

const isFivem =
  typeof GetParentResourceName === "function" ||
  (typeof window !== "undefined" && typeof window.invokeNative === "function");

const sortedFloors = computed(() => {
  const list = [...floors.value];

  const parseOrder = (floor) => {
    if (!floor) return 0;

    const direct =
      typeof floor.order === "number"
        ? floor.order
        : typeof floor.level === "number"
        ? floor.level
        : null;

    if (direct !== null) return direct;

    const raw = String(floor.id ?? floor.label ?? "").toUpperCase();

    if (raw.startsWith("B") && raw.length > 1) {
      const n = parseInt(raw.slice(1), 10);
      if (!Number.isNaN(n)) return -n;
    }

    const numeric = parseInt(raw, 10);
    if (!Number.isNaN(numeric)) return numeric;

    if (raw === "R" || raw === "ROOF" || raw === "PH") return 999;

    return 0;
  };

  list.sort((a, b) => parseOrder(b) - parseOrder(a));
  return list;
});

const isBellFloor = (floor) => {
  if (!floor) return false;
  const id = String(floor.id ?? "").toUpperCase();
  const label = String(floor.label ?? "").toUpperCase();
  return id === "BELL" || label === "BELL";
};

const floorButtons = computed(() => {
  return sortedFloors.value.filter((floor) => !isBellFloor(floor));
});

const floorsLayoutClass = computed(() => {
  const count = floorButtons.value.length;
  return count >= 4 ? "layout-two-columns" : "layout-single-column";
});

const displayButtons = computed(() => {
  const base = floorButtons.value;
  const count = base.length;

  // 4개 미만: 1열, 위에서 아래로 높은 층 -> 낮은 층 (기본 정렬 유지)
  if (count < 4) return base;

  // 4개 이상: 2열, 아래에서 위로 낮은 층 -> 높은 층, 각 행은 왼쪽이 더 낮은 층
  // base는 높은 층 -> 낮은 층 정렬이므로, 뒤집어서 낮은 층 -> 높은 층으로 만든다.
  const asc = [...base].reverse();

  const rows = [];
  for (let i = 0; i < asc.length; i += 2) {
    const left = asc[i];
    const right = asc[i + 1] ?? { __placeholder: true };
    rows.push([left, right]); // rows[0]가 맨 아래 행
  }

  const result = [];
  // DOM에서는 위에서 아래로 렌더되므로, 행을 위쪽 행부터 push한다.
  for (let r = rows.length - 1; r >= 0; r--) {
    const row = rows[r];
    result.push(row[0], row[1]);
  }

  return result;
});

const bellButton = computed(() => {
  return sortedFloors.value.find((floor) => isBellFloor(floor)) || null;
});

function postNui(endpoint, payload) {
  return fetch(`https://${resourceName}/${endpoint}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload ?? {}),
  }).catch(() => {});
}

function openMenu(data) {
  elevatorId.value = data.elevatorId || null;
  label.value = data.label || "Elevator";
  description.value = data.description || "";
  floors.value = Array.isArray(data.floors) ? data.floors : [];

  if (data && data.displayFloor != null) {
    displayFloor.value = String(data.displayFloor);
  } else if (floors.value.length > 0) {
    const first = floors.value[0];
    displayFloor.value = String(first.label ?? first.id ?? "");
  } else {
    displayFloor.value = "";
  }

  visible.value = true;
}

function close() {
  visible.value = false;
  postNui("close");
}

function selectFloor(floor) {
  if (!floor) return;
  displayFloor.value = String(floor.label ?? floor.id ?? "");
  postNui("selectFloor", {
    elevatorId: elevatorId.value,
    floorId: floor.id ?? floor.label,
  });
}

function handleNuiMessage(event) {
  const data = event.data;
  if (!data || !data.action) return;

  switch (data.action) {
    case "OPEN_MENU":
      openMenu(data);
      break;
    case "CLOSE_MENU":
      visible.value = false;
      break;
  }
}

function handleKeyDown(event) {
  if (!visible.value) return;

  if (event.key === "Escape") {
    event.preventDefault();
    close();
  }
}

function handleBackdropClick() {
  close();
}

onMounted(() => {
  window.addEventListener("message", handleNuiMessage);
  window.addEventListener("keydown", handleKeyDown, true);
  postNui("uiReady");

  if (!isFivem) {
    openMenu({
      elevatorId: "dev_elevator",
      label: "Test Elevator",
      description: "Dummy data for web preview",
      displayFloor: 12,
      floors: [
        // Upper floors
        { id: "12", label: "12F", description: "12th Floor", order: 12 },
        { id: "11", label: "11F", description: "11th Floor", order: 11 },
        { id: "10", label: "10F", description: "10th Floor", order: 10 },
        { id: "9", label: "9F", description: "9th Floor", order: 9 },
        { id: "8", label: "8F", description: "8th Floor", order: 8 },
        { id: "7", label: "7F", description: "7th Floor", order: 7 },
        { id: "6", label: "6F", description: "6th Floor", order: 6 },
        { id: "5", label: "5F", description: "5th Floor", order: 5 },
        { id: "4", label: "4F", description: "4th Floor", order: 4 },
        { id: "3", label: "3F", description: "3rd Floor", order: 3 },
        { id: "2", label: "2F", description: "2nd Floor", order: 2 },
        { id: "1", label: "1F", description: "1st Floor / Lobby", order: 1 },
        // Basements
        { id: "B1", label: "B1", description: "Basement 1", order: 0 },
        { id: "B2", label: "B2", description: "Basement 2", order: -1 },
        // Bell button (rendered below floors)
        { id: "BELL", label: "BELL", description: "Emergency bell", order: -2 },
      ],
    });
  }
});

onBeforeUnmount(() => {
  window.removeEventListener("message", handleNuiMessage);
  window.removeEventListener("keydown", handleKeyDown, true);
});
</script>
