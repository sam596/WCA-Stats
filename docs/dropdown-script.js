// JavaScript to handle dropdown menu functionality
document.addEventListener("DOMContentLoaded", function() {
    const dropdowns = document.getElementsByClassName("dropdown");
    for (let i = 0; i < dropdowns.length; i++) {
      const dropdown = dropdowns[i];
      dropdown.addEventListener("click", function() {
        this.classList.toggle("open");
        const dropdownContent = this.querySelector(".dropdown-content");
        if (dropdownContent.style.display === "block") {
          dropdownContent.style.display = "none";
          this.nextElementSibling.style.marginTop = "0";
        } else {
          dropdownContent.style.display = "block";
          this.nextElementSibling.style.marginTop = dropdownContent.offsetHeight + "px";
        }
      });
    }
  });