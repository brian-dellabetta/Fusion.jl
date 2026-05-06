import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.gridspec import GridSpec


def main():
    # ========== Parameters (common) ==========
    m = 0.5  # mass for massive particle (in atomic units)
    vF = 2.0  # Fermi velocity for massless particle
    k1 = 2.0  # right-moving wavepacket (positive momentum)
    k2 = -2.0  # left-moving wavepacket (negative momentum)
    sigma0 = 1.0  # initial width
    hbar = 1.0  # reduced Planck constant

    # Nuclear fusion parameters
    e2 = 1.44  # e²/(4πε₀) in MeV·fm for Coulomb barrier (repulsive)
    epsilon_regularize = 0.5  # regularization to avoid singularity

    # Spatial grid - 1D grids for x1 and x2
    comp_x_min, comp_x_max = -50.0, 50.0
    plot_x_min, plot_x_max = -25.0, 25.0
    nx = 512  # grid points per dimension (512x512 = 262k points)
    x1 = np.linspace(comp_x_min, comp_x_max, nx, endpoint=False)
    x2 = np.linspace(comp_x_min, comp_x_max, nx, endpoint=False)
    dx = x1[1] - x1[0]

    # Create 2D grids
    X1, X2 = np.meshgrid(x1, x2, indexing='ij')

    # Momentum grids
    p1 = 2.0 * np.pi * hbar * np.fft.fftfreq(nx, dx)
    p2 = 2.0 * np.pi * hbar * np.fft.fftfreq(nx, dx)
    P1, P2 = np.meshgrid(p1, p2, indexing='ij')

    # Time evolution parameters
    t_max = 12.0
    nt = 600
    t_vals = np.linspace(0, t_max, nt)
    steps_per_frame = 3
    dt = t_max / (nt * steps_per_frame)  # internal timestep
    dt_frame = t_max / nt  # time between animation frames

    # ========== Initial wavepackets ==========
    def make_wavepacket_1d(k, x0, x_grid):
        """Create normalized 1D Gaussian wavepacket"""
        psi = (1.0 / (2.0 * np.pi * sigma0**2)) ** 0.25 * np.exp(
            1j * k * x_grid - (x_grid - x0) ** 2 / (4.0 * sigma0**2)
        )
        psi /= np.sqrt(np.trapezoid(np.abs(psi) ** 2, x_grid))
        return psi

    x0_right = -8.0  # right-moving starts at x=-8
    x0_left = 8.0  # left-moving starts at x=+8

    # Create product state: ψ(x1,x2) = ψ_right(x1) * ψ_left(x2)
    psi1_1d = make_wavepacket_1d(k1, x0_right, x1)  # particle 1: right-moving
    psi2_1d = make_wavepacket_1d(k2, x0_left, x2)   # particle 2: left-moving

    # Initial 2D wavefunctions (product states)
    psi_init = np.outer(psi1_1d, psi2_1d)  # ψ(x1,x2) = ψ1(x1)ψ2(x2)

    # Normalize 2D wavefunction
    norm = np.sqrt(np.trapezoid(np.trapezoid(np.abs(psi_init)**2, x2, axis=1), x1))
    psi_init /= norm

    # Four cases
    psi_mw = psi_init.copy()    # massive with backscattering
    psi_mwo = psi_init.copy()   # massive without backscattering
    psi_mlw = psi_init.copy()   # massless with backscattering

    # Massless spin-locked: enforce topological constraint on initial state
    psi_mlwo = psi_init.copy()
    # Project to enforce p1 > 0, p2 < 0 (spin-momentum locking)
    psi_mlwo_k = np.fft.fft2(psi_mlwo)
    # Kill forbidden momentum components
    psi_mlwo_k[p1 < 0, :] = 0  # Particle 1: only right-moving (p1 > 0)
    psi_mlwo_k[:, p2 > 0] = 0  # Particle 2: only left-moving (p2 < 0)
    psi_mlwo = np.fft.ifft2(psi_mlwo_k)
    # Renormalize after projection
    norm = np.sqrt(np.trapezoid(np.trapezoid(np.abs(psi_mlwo)**2, x2, axis=1), x1))
    psi_mlwo /= norm

    # ========== Precompute kinetic factors ==========
    # Massive: H_kin = p1²/(2m) + p2²/(2m)
    exp_kin_massive = np.exp(-1j * (P1**2 + P2**2) * dt / (2.0 * m * hbar))

    # Massless ordinary: H_kin = vF(|p1| + |p2|)
    exp_kin_massless = np.exp(-1j * vF * (np.abs(P1) + np.abs(P2)) * dt / hbar)

    # Massless spin-locked: H_kin = vF·p1 (spin-up, right) + vF·(-p2) (spin-down, left)
    # Simplified: H_kin = vF(p1 - p2)
    exp_kin_massless_spinlock = np.exp(-1j * vF * (P1 - P2) * dt / hbar)

    # Projection operator for spin-momentum locking
    # Particle 1: only p1 > 0 (right-moving, spin-up)
    # Particle 2: only p2 < 0 (left-moving, spin-down)
    spinlock_projector = np.ones_like(P1)
    spinlock_projector[p1 < 0, :] = 0  # Kill left-moving components of particle 1
    spinlock_projector[:, p2 > 0] = 0  # Kill right-moving components of particle 2

    # ========== Nuclear fusion potential ==========
    def coulomb_potential(psi):
        """
        Coulomb repulsion barrier: V = e²/|r|
        where r = |x₁ - x₂|

        Regularized to avoid singularity at r=0
        """
        # Relative separation
        r = np.abs(X1 - X2)

        # Regularized Coulomb: e²/sqrt(r² + ε²) to avoid singularity
        V = e2 / np.sqrt(r**2 + epsilon_regularize**2)
        return V

    # ========== Figure setup: 2 rows x 2 columns ==========
    fig = plt.figure(figsize=(16, 10))
    gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

    titles = [
        "Massive particles + Coulomb repulsion",
        "Free massive particles (no interaction)",
        "Massless particles + Coulomb repulsion",
        "QSH edge state + Coulomb (topologically protected)",
    ]

    # Create subplots with twin axes
    axs = []
    ax_twins = []
    for idx, (row, col) in enumerate([(0, 0), (0, 1), (1, 0), (1, 1)]):
        ax = fig.add_subplot(gs[row, col])
        axs.append(ax)
        ax_twin = ax.twinx()
        ax_twins.append(ax_twin)

    # Storage for lines
    rho1_lines = []  # marginal density for particle 1
    rho2_lines = []  # marginal density for particle 2
    contact_lines = []  # contact density |ψ(x,x)|²
    fusion_lines = []  # cumulative fusion probability

    # History storage
    raw_contact_history = [[] for _ in range(4)]
    cum_residence_time = [0.0 for _ in range(4)]  # cumulative residence time (fusion probability)

    colors = ["blue", "cyan", "red", "orange"]

    for idx, ax in enumerate(axs):
        row = idx // 2
        if row == 0:
            cols = ["blue", "cyan"]
        else:
            cols = ["red", "orange"]

        # Lines for marginal densities
        (line_rho1,) = ax.plot([], [], lw=2, color=cols[0], label="ρ₁(x₁)")
        (line_rho2,) = ax.plot([], [], lw=2, color=cols[1], label="ρ₂(x₂)")
        rho1_lines.append(line_rho1)
        rho2_lines.append(line_rho2)

        ax.set_xlim(plot_x_min, plot_x_max)
        ax.set_ylim(0, 0.6)
        ax.set_xlabel("Position x")
        ax.set_ylabel("Marginal density")
        ax.grid(True, alpha=0.3)
        ax.set_title(titles[idx])
        ax.legend(loc="upper right")

        # Twin axis for contact density and fusion probability
        ax_twin = ax_twins[idx]
        ax_twin.set_ylabel("Contact (purple) / Residence time (orange)", color="black")
        ax_twin.tick_params(axis="y", labelcolor="black")
        ax_twin.set_ylim(0, 1.0)

        # Purple line for normalized contact density
        (contact_line,) = ax_twin.plot([], [], lw=2, color="purple", linestyle="-",
                                       label="Contact")
        contact_lines.append(contact_line)

        # Orange dashed line for normalized cumulative residence time (fusion probability)
        (fusion_line,) = ax_twin.plot([], [], lw=2, color="orange", linestyle="--",
                                      label="Residence")
        fusion_lines.append(fusion_line)

        if idx == 1:  # Add legend to top-right subplot
            ax_twin.legend(loc="upper left")

    plt.tight_layout(pad=2.0)

    # ========== Initialization function ==========
    def init():
        for idx in range(4):
            rho1_lines[idx].set_data([], [])
            rho2_lines[idx].set_data([], [])
            contact_lines[idx].set_data([], [])
            fusion_lines[idx].set_data([], [])
            raw_contact_history[idx] = []
            cum_residence_time[idx] = 0.0
        return rho1_lines + rho2_lines + contact_lines + fusion_lines

    # ========== Animation update function ==========
    def animate(i):
        nonlocal psi_mw, psi_mwo, psi_mlw, psi_mlwo
        t = t_vals[i]

        # Update titles
        for idx, ax in enumerate(axs):
            ax.set_title(f"{titles[idx]}, t={t:.2f}")

        # Propagation helper
        def propagate_2d(psi, get_potential, exp_kin):
            """Split-operator propagation in 2D config space"""
            for _ in range(steps_per_frame):
                # Half-step potential
                V = get_potential(psi)
                psi *= np.exp(-1j * V * dt / (2.0 * hbar))

                # Full-step kinetic (2D FFT)
                psi_k = np.fft.fft2(psi)
                psi_k *= exp_kin
                psi = np.fft.ifft2(psi_k)

                # Half-step potential
                V = get_potential(psi)
                psi *= np.exp(-1j * V * dt / (2.0 * hbar))
            return psi

        # 1) Massive with Coulomb barrier (conventional fusion)
        psi_mw = propagate_2d(psi_mw, coulomb_potential, exp_kin_massive)

        # 2) Massive without interaction (free, reference)
        psi_mwo = propagate_2d(psi_mwo, lambda p: np.zeros_like(p), exp_kin_massive)

        # 3) Massless with Coulomb barrier (no topological protection)
        psi_mlw = propagate_2d(psi_mlw, coulomb_potential, exp_kin_massless)

        # 4) QSH edge state with Coulomb barrier (topologically protected!)
        # No explicit projection needed - the Hamiltonian and initial state
        # naturally preserve spin-momentum locking if the interaction is spin-conserving
        psi_mlwo = propagate_2d(psi_mlwo, coulomb_potential, exp_kin_massless_spinlock)

        # Compute observables for all cases
        psi_list = [psi_mw, psi_mwo, psi_mlw, psi_mlwo]

        for idx, psi in enumerate(psi_list):
            # Marginal densities: ρ₁(x₁) = ∫|ψ(x₁,x₂)|²dx₂
            rho1 = np.trapezoid(np.abs(psi)**2, x2, axis=1)
            # ρ₂(x₂) = ∫|ψ(x₁,x₂)|²dx₁
            rho2 = np.trapezoid(np.abs(psi)**2, x1, axis=0)

            # Contact density: integral of |ψ(x,x)|² (density along diagonal)
            # Extract diagonal values
            contact_density = np.sum(np.abs(np.diag(psi))**2) * dx

            # Store raw contact density
            raw_contact_history[idx].append(contact_density)

            # ========== Fusion Probability = Residence Time ==========
            # Accumulate contact density over time (measures how long particles are close)
            cum_residence_time[idx] += contact_density * dt_frame

            # Update marginal density lines
            rho1_lines[idx].set_data(x1, rho1)
            rho2_lines[idx].set_data(x2, rho2)

        # Find global max contact density across all cases and all time
        max_contact = max(
            max(raw_contact_history[idx]) if len(raw_contact_history[idx]) > 0 else 0
            for idx in range(4)
        )

        # Find global max cumulative residence time across all cases
        max_residence = max(cum_residence_time)

        # Re-normalize and plot contact density history
        for idx in range(4):
            xd = t_vals[:len(raw_contact_history[idx])]
            if max_contact > 0:
                yd = [val / max_contact for val in raw_contact_history[idx]]
            else:
                yd = raw_contact_history[idx]
            contact_lines[idx].set_data(xd, yd)

        # Plot normalized cumulative residence time (fusion probability)
        # Build cumulative history from raw contact densities
        for idx in range(4):
            cum_history = []
            cumsum = 0.0
            for contact_val in raw_contact_history[idx]:
                cumsum += contact_val * dt_frame  # use frame timestep, not internal timestep
                cum_history.append(cumsum)

            xd = t_vals[:len(cum_history)]
            if max_residence > 0:
                yd = [val / max_residence for val in cum_history]
            else:
                yd = cum_history
            fusion_lines[idx].set_data(xd, yd)

        # Print diagnostics including momentum distribution
        if i % 20 == 0:  # Print every 20 frames
            print(f"\nt={t:.3f}:")
            print(f"  Contact densities: MW={raw_contact_history[0][-1]:.6e}, "
                  f"MWO={raw_contact_history[1][-1]:.6e}, MLW={raw_contact_history[2][-1]:.6e}, "
                  f"MLWO={raw_contact_history[3][-1]:.6e}")
            print(f"  Residence time (fusion prob): MW={cum_residence_time[0]:.6e}, "
                  f"MWO={cum_residence_time[1]:.6e}, MLW={cum_residence_time[2]:.6e}, "
                  f"MLWO={cum_residence_time[3]:.6e}")

            # Check momentum distribution for QSH case
            psi_mlwo_k = np.fft.fft2(psi_mlwo)
            phi_k = np.abs(psi_mlwo_k)**2

            # Find peak momentum
            p1_avg = np.sum(P1 * phi_k) / np.sum(phi_k)
            p2_avg = np.sum(P2 * phi_k) / np.sum(phi_k)

            # Check for backscattered components
            prob_p1_negative = np.sum(phi_k[p1 < 0, :]) / np.sum(phi_k)
            prob_p2_positive = np.sum(phi_k[:, p2 > 0]) / np.sum(phi_k)

            print(f"  QSH momentum: ⟨p1⟩={p1_avg:.3f}, ⟨p2⟩={p2_avg:.3f}, p1-p2={p1_avg-p2_avg:.3f}")
            print(f"  QSH forbidden states: P(p1<0)={prob_p1_negative:.6e}, P(p2>0)={prob_p2_positive:.6e}")

        return rho1_lines + rho2_lines + contact_lines + fusion_lines

    # ========== Create animation ==========
    anim = animation.FuncAnimation(
        fig, animate, init_func=init, frames=nt, interval=50, blit=False
    )

    # Save
    filename = "topological_fusion_comparison.mp4"
    anim.save(filename, writer="ffmpeg", fps=30)
    print(f"Saved animation as {filename}")
    print("\nComparison scenarios (Coulomb barrier only):")
    print("1. Top-left: Massive particles + Coulomb repulsion")
    print("2. Top-right: Free massive particles (no interaction)")
    print("3. Bottom-left: Massless particles + Coulomb repulsion")
    print("4. Bottom-right: QSH edge state (topologically protected, no backscattering)")

    plt.close()


if __name__ == "__main__":
    main()
