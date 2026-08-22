const form = document.getElementById("advisor-form");
const formMessage = document.getElementById("form-message");
const generateButton = form.querySelector('button[type="submit"]');
const priorityInputs = Array.from(
    document.querySelectorAll('input[name="priorities"]')
);

const MIN_PRIORITIES = 1;
const MAX_PRIORITIES = 3;

const apiUrl = window.ADVISOR_CONFIG?.apiUrl;

const recommendationEmpty = document.getElementById("recommendation-empty");
const recommendationPanel = document.getElementById("recommendation");
const recommendationStatus = document.getElementById("recommendation-status");
const architectureName = document.getElementById("architecture-name");
const architectureSummary = document.getElementById("architecture-summary");
const recommendedServices = document.getElementById("recommended-services");

const designCompute = document.getElementById("design-compute");
const designNetworking = document.getElementById("design-networking");
const designData = document.getElementById("design-data");
const designSecurity = document.getElementById("design-security");
const designObservability = document.getElementById("design-observability");

const wellArchitectedAssessments = document.getElementById(
    "well-architected-assessments"
);
const tradeoffsList = document.getElementById("tradeoffs");
const nextStepsList = document.getElementById("next-steps");

if (!apiUrl) {
    throw new Error("Advisor API URL is not configured.");
}

function getSelectedPriorities() {
    return priorityInputs.filter((input) => input.checked);
}

function buildAdvisorRequest() {
    const formData = new FormData(form);

    return {
        workload_type: formData.get("workload_type"),
        traffic_pattern: formData.get("traffic_pattern"),
        availability_requirement: formData.get("availability_requirement"),
        data_requirement: formData.get("data_requirement"),
        expected_scale: formData.get("expected_scale"),
        priorities: getSelectedPriorities().map((input) => input.value),
    };
}

function renderRecommendationSummary(recommendation) {
    architectureName.textContent = recommendation.architecture_name;
    architectureSummary.textContent = recommendation.summary;

    recommendationEmpty.hidden = true;
    recommendationPanel.hidden = false;
    recommendationStatus.textContent = "Recommendation ready";
}

function renderRecommendedServices(services) {
    recommendedServices.replaceChildren();

    services.forEach((service) => {
        const card = document.createElement("article");
        card.className = "service-card";

        const serviceName = document.createElement("h4");
        serviceName.textContent = service.service;

        const purpose = document.createElement("p");
        purpose.textContent = service.purpose;

        card.append(serviceName, purpose);
        recommendedServices.append(card);
    });
}

function renderArchitectureDesign(design) {
    designCompute.textContent = design.compute;
    designNetworking.textContent = design.networking;
    designData.textContent = design.data;
    designSecurity.textContent = design.security;
    designObservability.textContent = design.observability;
}

function renderWellArchitectedAssessments(assessments) {
    wellArchitectedAssessments.replaceChildren();

    Object.entries(assessments).forEach(([priority, assessment]) => {
        const section = document.createElement("article");
        section.className = "assessment-card";

        const heading = document.createElement("h4");
        heading.textContent = priority
            .split("_")
            .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
            .join(" ");

        const content = document.createElement("div");
        content.className = "assessment-grid";

        const strengths = document.createElement("div");
        const strengthsHeading = document.createElement("h5");
        strengthsHeading.textContent = "Strengths";

        const strengthsList = document.createElement("ul");

        assessment.strengths.forEach((strength) => {
            const item = document.createElement("li");
            item.textContent = strength;
            strengthsList.append(item);
        });

        strengths.append(strengthsHeading, strengthsList);

        const considerations = document.createElement("div");
        const considerationsHeading = document.createElement("h5");
        considerationsHeading.textContent = "Considerations";

        const considerationsList = document.createElement("ul");

        assessment.considerations.forEach((consideration) => {
            const item = document.createElement("li");
            item.textContent = consideration;
            considerationsList.append(item);
        });

        considerations.append(
            considerationsHeading,
            considerationsList
        );

        content.append(strengths, considerations);
        section.append(heading, content);
        wellArchitectedAssessments.append(section);
    });
}

function renderTradeoffs(tradeoffs) {
    tradeoffsList.replaceChildren();

    tradeoffs.forEach((tradeoff) => {
        const item = document.createElement("li");
        item.textContent = tradeoff;
        tradeoffsList.append(item);
    });
}

function renderNextSteps(nextSteps) {
    nextStepsList.replaceChildren();

    nextSteps.forEach((nextStep) => {
        const item = document.createElement("li");
        item.textContent = nextStep;
        nextStepsList.append(item);
    });
}

function clearRecommendationContent() {
    architectureName.textContent = "";
    architectureSummary.textContent = "";

    recommendedServices.replaceChildren();

    designCompute.textContent = "";
    designNetworking.textContent = "";
    designData.textContent = "";
    designSecurity.textContent = "";
    designObservability.textContent = "";

    wellArchitectedAssessments.replaceChildren();
    tradeoffsList.replaceChildren();
    nextStepsList.replaceChildren();
}

function resetRecommendation() {
    clearRecommendationContent();

    recommendationPanel.hidden = true;
    recommendationEmpty.hidden = false;
    recommendationStatus.textContent = "Waiting for input";
}

function setLoadingState(isLoading) {
    generateButton.disabled = isLoading;
    generateButton.textContent = isLoading
        ? "Generating..."
        : "Generate Architecture";

    if (isLoading) {
        recommendationStatus.textContent = "Analyzing workload";
        formMessage.textContent = "Generating architecture recommendation...";
    }
}

function updatePriorityState() {
    const selected = getSelectedPriorities();
    const maximumReached = selected.length >= MAX_PRIORITIES;

    priorityInputs.forEach((input) => {
        input.disabled = maximumReached && !input.checked;
    });

    if (selected.length === MAX_PRIORITIES) {
        formMessage.textContent =
            "Maximum of three architecture priorities selected.";
    } else {
        formMessage.textContent = "";
    }
}

priorityInputs.forEach((input) => {
    input.addEventListener("change", updatePriorityState);
});

form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const selected = getSelectedPriorities();

    if (selected.length < MIN_PRIORITIES) {
        formMessage.textContent =
            "Select at least one architecture priority.";
        return;
    }

    formMessage.textContent = "";

    const request = buildAdvisorRequest();

    clearRecommendationContent();
    recommendationPanel.hidden = true;
    recommendationEmpty.hidden = false;

    setLoadingState(true);

    try {
        const response = await fetch(`${apiUrl}/advise`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify(request),
        });

        if (!response.ok) {
            throw new Error(
                `Advisor request failed with HTTP ${response.status}.`
            );
        }

        const recommendation = await response.json();

        renderRecommendationSummary(recommendation);
        renderRecommendedServices(recommendation.services);
        renderArchitectureDesign(recommendation.design);
        renderWellArchitectedAssessments(recommendation.well_architected);
        renderTradeoffs(recommendation.tradeoffs);
        renderNextSteps(recommendation.next_steps);

        formMessage.textContent =
            "Architecture recommendation generated successfully.";
    } catch (error) {
        console.error("Advisor request failed:", error);

        recommendationStatus.textContent = "Request failed";
        formMessage.textContent =
            "Unable to generate an architecture recommendation. Please try again.";
    } finally {
        setLoadingState(false);
    }
});

form.addEventListener("reset", () => {
    window.setTimeout(() => {
        priorityInputs.forEach((input) => {
            input.disabled = false;
        });

        formMessage.textContent = "";
        resetRecommendation();
    }, 0);
});

updatePriorityState();
